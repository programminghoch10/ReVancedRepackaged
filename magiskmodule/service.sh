#!/system/bin/sh
cd $(dirname $0)

source ./version.sh

err() {
    local msg="ReVancedRepackaged: $1"
    log -t Magisk "$msg"
    echo "$msg" >> /cache/magisk.log
    touch disable
    exit 1
}

REVANCEDAPK="$(pwd)"/revanced.apk
[ ! -f "$REVANCEDAPK" ] && err "Missing $REVANCEDAPK"

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
done

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MIRROR="$MAGISKTMP"/.magisk/mirror

youtubeapkpath=$(pm path "$YOUTUBE_PACKAGE" \
    | grep -E 'package:.*/base\.apk' \
    | cut -d':' -f2)

[ -z "$youtubeapkpath" ] && \
    youtubeapkpath=$(find -H \
    "$MIRROR"/data/app \
    -wholename "*${YOUTUBE_PACKAGE}*/base.apk")

[ -z "$youtubeapkpath" ] && err "Couldn't locate YouTube base.apk"

mount -o bind "$MIRROR"/"$REVANCEDAPK" "$youtubeapkpath" \
    || err "Failed to mount $REVANCEDAPK on $youtubeapkpath"

am force-stop "$YOUTUBE_PACKAGE"
