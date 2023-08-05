#!/bin/bash
set -e

for cmd in git wget zip java; do
    [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

[ -f .gitauth ] && source .gitauth
[ -z "$GITHUB_ACTOR" ] && echo "missing GITHUB_ACTOR" && exit 1
[ -z "$GITHUB_TOKEN" ] && echo "missing GITHUB_TOKEN" && exit 1

declare -x GITHUB_ACTOR GITHUB_TOKEN
REVANCED_INTEGRATIONS_URL="https://github.com/revanced/revanced-integrations/releases/download/v%s/revanced-integrations-%s.apk"
REVANCED_PATCHES_URL="https://github.com/revanced/revanced-patches/releases/download/v%s/revanced-patches-%s.jar"

git submodule update --checkout
git clean -fdx magiskmodule/

executeGradle() {
    (
        cd revanced-android
        ./gradlew "$@"
    )
}

[ "$1" = "clean" ] && {
    executeGradle clean
    exit
}

(
    cd revanced-cli
    for patch in $(ls ../revanced-cli-patches/*.patch); do
        git am --no-3way "$patch"
    done
)

executeGradle assemble :revancedcli:shadowJar

git submodule update --checkout

source version.sh

REVANCED_INTEGRATIONS=$(sed -e 's/^v//' <<< "$REVANCED_INTEGRATIONS")
printf -v REVANCED_INTEGRATIONS_DL "$REVANCED_INTEGRATIONS_URL" "$REVANCED_INTEGRATIONS" "$REVANCED_INTEGRATIONS"
REVANCED_PATCHES=$(sed -e 's/^v//' <<< "$REVANCED_PATCHES")
printf -v REVANCED_PATCHES_DL "$REVANCED_PATCHES_URL" "$REVANCED_PATCHES" "$REVANCED_PATCHES"

for dlurl in "$REVANCED_INTEGRATIONS_DL" "$REVANCED_PATCHES_DL"; do
    dlfile="$(basename "$dlurl")"
    [ ! -f "$dlfile" ] && wget -c -O "$dlfile" "$dlurl"
done

REVANCED_CLI=$(sed -e 's/^v//' <<< "$REVANCED_CLI")
ln -v -s -f "revanced-cli/build/libs/revancedcli-$REVANCED_CLI-all.jar" "revanced-cli.jar"

PATCHES_LIST=$(java -jar revanced-cli.jar \
    -b "$(basename "$REVANCED_PATCHES_DL")" \
    -a dummy.apk \
    --list \
    --with-versions \
    --with-packages \
| sed 's/^INFORMATION: \s*//')
rm -rf magiskmodule/packageversions
mkdir magiskmodule/packageversions
echo '## Supported Packages and Versions' > magiskmodule/supportedversions.md
for package in $(cut -d$'\t' -f1 <<< "$PATCHES_LIST" | sort -u); do
    cut -d$'\t' -f1,4 <<< "$PATCHES_LIST" | grep "^$package" | cut -d$'\t' -f2 | tr ',' '\n' | sed -e 's/^ //' -e 's/ $//' -e '/^$/d' | sort -u > magiskmodule/packageversions/"$package"
    echo "- **\`$package\`**" >> magiskmodule/supportedversions.md
    sed 's/^\(.*\)$/`\1`/' < magiskmodule/packageversions/"$package" | tr '\n' '#' | sed -e '/^$/d' -e 's/#$//' -e 's/#/\n/g' | sed -e 's/^/  - /' >> magiskmodule/supportedversions.md
    [ $(wc -l < magiskmodule/packageversions/"$package") -gt 0 ] && echo >> magiskmodule/supportedversions.md
done

cp -v revanced-android/revancedcliwrapper/build/outputs/apk/release/revancedcliwrapper-release.apk magiskmodule/revancedandroidcli.apk
cp -v "$(basename "$REVANCED_INTEGRATIONS_DL")" magiskmodule/integrations.apk
cp -v "$(basename "$REVANCED_PATCHES_DL")" magiskmodule/patches.jar
cp -r -v --no-target-directory aapt2 magiskmodule/aapt2lib
cp README.md magiskmodule/README.md

[ -n "$(git status --porcelain)" ] && CHANGES="+" || CHANGES="-"
VERSIONCODE=$(git rev-list --count HEAD)
COMMITHASH=$(git log -1 --pretty=%h)
VERSIONNAME=v${VERSIONCODE}${CHANGES}${COMMITHASH}
OUTFILENAME="ReVancedRepackaged-${VERSIONNAME}.zip"

declare -x VERSIONCODE VERSIONNAME
envsubst < module.prop > magiskmodule/module.prop

cp version.sh magiskmodule/version.sh

rm -f ReVancedRepackaged-*.zip
(
    cd magiskmodule
    zip -r -9 ../"$OUTFILENAME" .
)
