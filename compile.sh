#!/bin/bash
set -e

for cmd in git wget zip java; do
    [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

[ -f .gitauth ] && source .gitauth
[ -z "$GITHUB_ACTOR" ] && echo "missing GITHUB_ACTOR" && exit 1
[ -z "$GITHUB_TOKEN" ] && echo "missing GITHUB_TOKEN" && exit 1

declare -x GITHUB_ACTOR GITHUB_TOKEN
REVANCED_PATCHES_URL="https://github.com/revanced/revanced-patches/releases/download/v%s/patches-%s.rvp"

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
    for patch in ../revanced-cli-patches/*.patch; do
        git am --no-3way "$patch"
    done
)

executeGradle assemble :revancedcli:shadowJar

git submodule update --checkout

source version.sh

REVANCED_PATCHES=${REVANCED_PATCHES#v}
printf -v REVANCED_PATCHES_DL "$REVANCED_PATCHES_URL" "$REVANCED_PATCHES" "$REVANCED_PATCHES"
[ ! -f "$(basename "$REVANCED_PATCHES_DL")" ] && wget -c -O "$(basename "$REVANCED_PATCHES_DL")" "$REVANCED_PATCHES_DL"

REVANCED_CLI=${REVANCED_CLI#v}
ln -v -s -f "revanced-cli/build/libs/revancedcli-$REVANCED_CLI-all.jar" "revanced-cli.jar"

PATCHES_LIST=$(java -jar revanced-cli.jar \
    list-packages \
    "$(basename "$REVANCED_PATCHES_DL")" \
| sed 's/^INFORMATION: \s*//')
rm -rf magiskmodule/packageversions
mkdir magiskmodule/packageversions
echo '## Supported Packages and Versions' > magiskmodule/supportedversions.md
cut -d$'\t' -f1 <<< "$PATCHES_LIST" | sort -u | while IFS= read -r package; do
    grep "^$package" <<< "$PATCHES_LIST" | cut -d$'\t' -f2 | tr ',' '\n' | sed -e 's/^ //' -e 's/ $//' -e '/^$/d' | sort -u > magiskmodule/packageversions/"$package"
    echo "- **\`$package\`**" >> magiskmodule/supportedversions.md
    #shellcheck disable=SC2016
    sed 's/^\(.*\)$/`\1`/' < magiskmodule/packageversions/"$package" | tr '\n' '#' | sed -e '/^$/d' -e 's/#$//' -e 's/#/\n/g' | sed -e 's/^/  - /' >> magiskmodule/supportedversions.md
    [ "$(wc -l < magiskmodule/packageversions/"$package")" -gt 0 ] && echo >> magiskmodule/supportedversions.md
done

logo/convert.sh

cp -v revanced-android/revancedcliwrapper/build/outputs/apk/release/revancedcliwrapper-release.apk magiskmodule/revancedandroidcli.apk
cp -v "$(basename "$REVANCED_PATCHES_DL")" magiskmodule/patches.rvp
cp -r -v --no-target-directory aapt2 magiskmodule/aapt2lib
cp -r --no-target-directory logo/assets magiskmodule/logo
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
