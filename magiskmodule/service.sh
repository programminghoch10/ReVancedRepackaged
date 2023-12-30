#!/system/bin/sh
cd "$(dirname "$0")"

. ./version.sh

logi() {
    msg="ReVancedRepackaged: $1"
    log -t Magisk "$msg"
    echo "$msg" >> /cache/magisk.log
}

[ -z "$(ls overlay)" ] && logi "No overlays found!" && touch remove && exit 1

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MIRROR="$MAGISKTMP"/.magisk/mirror

checkHash() {
    packagename="$1"
    apkpath="$2"
    [ "$(sha256sum < "$apkpath")" = "$(cat overlay/"$packagename".sha256sum)" ] && return 0
    logi "Package $packagename has changed their base.apk! Removing their overlay, because a repatch is required."
    rm overlay/"$packagename".*
    return 1
}

overlayPackage() {
    packagename="$1"
    logi "Overlaying $packagename"

    overlayapk=$(pwd)/overlay/"$packagename".apk

    apkpath=$(pm path "$packagename" \
        | grep -E 'package:.*/base\.apk' \
        | cut -d':' -f2)

    [ -z "$apkpath" ] && \
        apkpath=$(find -H \
        "$MIRROR"/data/app \
        -wholename "*${packagename}*/base.apk")

    [ -z "$apkpath" ] \
        && logi "Couldn't locate $packagename base.apk" \
        && return 1

    checkHash "$packagename" "$apkpath" || return 1

    mount -o bind "$MIRROR"/"$overlayapk" "$apkpath" || {
        logi "Failed to mount $overlayapk on $apkpath"
        return 1
    }

    am force-stop "$packagename"
}

for packagename in overlay/*.apk; do
    packagename="$(basename "$packagename" | sed -e 's/\.apk$//')"
    overlayPackage "$packagename"
done
