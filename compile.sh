#!/bin/bash
set -e

[ -f .gitauth ] && source .gitauth
[ -z "$GITHUB_ACTOR" ] && echo "missing GITHUB_ACTOR" && exit 1
[ -z "$GITHUB_TOKEN" ] && echo "missing GITHUB_TOKEN" && exit 1
declare -x GITHUB_ACTOR GITHUB_TOKEN

git submodule update --checkout

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
    git am ../0001-Load-classes-in-dex-mode.patch
)

executeGradle assemble

git submodule update --checkout

source version.sh

for dlurl in "$REVANCED_INTEGRATIONS" "$REVANCED_PATCHES"; do
    dlfile="$(basename "$dlurl")"
    [ ! -f "$dlfile" ] && wget -c -O "$dlfile" "$dlurl"
done

cp -v revanced-android/revancedcliwrapper/build/outputs/apk/release/revancedcliwrapper-release.apk magiskmodule/wrapper.apk
cp -v "$(basename "$REVANCED_INTEGRATIONS")" magiskmodule/integrations.apk
cp -v "$(basename "$REVANCED_PATCHES")" magiskmodule/patches.jar
cp -r -v aapt2 magiskmodule/
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
