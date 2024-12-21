#!/bin/bash
set -e
shopt -s inherit_errexit
set -o pipefail

for cmd in git wget zip java; do
    [ -z "$(command -v "$cmd")" ] && echo "missing $cmd" && exit 1
done

[ -f .gitauth ] && source .gitauth
[ -z "$GITHUB_ACTOR" ] && echo "missing GITHUB_ACTOR" && exit 1
[ -z "$GITHUB_TOKEN" ] && echo "missing GITHUB_TOKEN" && exit 1

declare -x GITHUB_ACTOR GITHUB_TOKEN

git submodule update --checkout
git clean -fdx magiskmodule/

executeGradle() {
    (
        cd "$1"
        shift
        ./gradlew "$@"
    )
}
applyPatches() {
    (
        cd "$1"
        for patch in ../"$1"-patches/*.patch; do
            git am --no-3way "$patch"
        done
    )
}

[ "$1" = "clean" ] && {
    executeGradle revanced-android clean
    executeGradle revanced-patches clean
    exit
}

applyPatches revanced-cli
executeGradle revanced-android assemble :revancedcli:shadowJar

applyPatches revanced-patches
executeGradle revanced-patches buildAndroid

git submodule update --checkout

source version.sh

REVANCED_PATCHES=${REVANCED_PATCHES#v}
REVANCED_CLI=${REVANCED_CLI#v}
ln -v -s -f revanced-cli/build/libs/revancedcli-"$REVANCED_CLI"-all.jar revanced-cli.jar

PATCHES_LIST=$(java -jar revanced-cli.jar \
    list-packages \
    revanced-patches/patches/build/libs/patches-"$REVANCED_PATCHES".rvp \
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
    true
done

logo/convert.sh

cp -v revanced-android/revancedcliwrapper/build/outputs/apk/release/revancedcliwrapper-release.apk magiskmodule/revancedandroidcli.apk
cp -v revanced-patches/patches/build/libs/patches-"$REVANCED_PATCHES".rvp magiskmodule/patches.rvp
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
