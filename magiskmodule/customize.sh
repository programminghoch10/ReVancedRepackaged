#!/system/bin/sh

[ "$BOOTMODE" != "true" ] && abort "Please install this module within the Magisk app."

export IFS=$'\n'

cd "$MODPATH"

[ ! -f ./version.sh ] && abort "Missing version.sh"
source ./version.sh

[ -z "$(pm list packages "$YOUTUBE_PACKAGE")" ] && {
    ui_print "YouTube not found."
    abort "Please install YouTube $YOUTUBE_VERSION manually before installing this module."
}

installedyoutubeversion="$(pm dump $YOUTUBE_PACKAGE | grep -E '^ *versionName=.*$' | cut -d'=' -f2)"

[ "$installedyoutubeversion" != "$YOUTUBE_VERSION" ] && {
    ui_print "YouTube version mismatch!"
    ui_print "  Found:    $installedyoutubeversion"
    ui_print "  Expected: $YOUTUBE_VERSION"
    abort "Please install the correct YouTube version before installing this module."
}
ui_print "- Found YouTube $installedyoutubeversion"

youtubeapkpath=$(pm path "$YOUTUBE_PACKAGE" | grep -E 'package:.*/base\.apk' | cut -d':' -f2)
ui_print "- Found YouTube APK at $youtubeapkpath"

ui_print "- Preparing Patching Process"

cp -v wrapper.apk patches.jar integrations.apk "$TMPDIR"

[ ! -f aapt2/$ARCH/libaapt2.so ] && abort "Failed to locate libaapt2.so for $ARCH"
cp -v aapt2/$ARCH/libaapt2.so "$TMPDIR"/aapt2
chmod -v +x "$TMPDIR"/aapt2

cd "$TMPDIR"
ui_print "   TMPDIR=$TMPDIR"

ui_print "- Patching YouTube APK"

app_process \
    -cp wrapper.apk \
    $(pwd) \
    com.programminghoch10.revancedandroidcli.MainCommand \
    -a "$youtubeapkpath" \
    -c \
    -o revanced.apk \
    -b patches.jar \
    -m integrations.apk \
    -e vanced-microg-support \
    --custom-aapt2-binary=$(pwd)/aapt2 \
2>&1 || abort "Patching failed! $?"

[ ! -f revanced.apk ] && abort "Patching failed!"

mv -v revanced.apk "$MODPATH"/revanced.apk
rm aapt2

cd "$MODPATH"

chcon u:object_r:apk_data_file:s0 revanced.apk

rm wrapper.apk integrations.apk patches.jar
rm -r aapt2
