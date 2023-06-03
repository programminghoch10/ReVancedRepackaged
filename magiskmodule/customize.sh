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
