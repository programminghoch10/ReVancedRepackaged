#!/system/bin/sh

[ "$BOOTMODE" != "true" ] && abort "Please install this module within the Magisk app."

export IFS=$'\n'

cd "$MODPATH"

[ ! -f ./version.sh ] && abort "Missing version.sh"
source ./version.sh

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MIRROR="$MAGISKTMP"/.magisk/mirror
ui_print "- Found Magisk mirror at $MIRROR"

ui_print "- Preparing Patching Process"

[ ! -f aapt2lib/$ARCH/libaapt2.so ] && abort "Failed to locate libaapt2.so for $ARCH"
mv -v aapt2lib/$ARCH/libaapt2.so aapt2
rm -r aapt2lib
chmod -v +x aapt2

chmod -v +x system/bin/revancedcli

mkdir overlay

processPackage() {
    local packagename="$1"

    [ -z "$(pm list packages "$packagename")" ] && {
        #ui_print "- $packagename not found"
        return
    }

    ui_print "- Processing $packagename"

    installedpackageversion="$(pm dump $packagename | grep -E '^ *versionName=.*$' | cut -d'=' -f2)"

    grep -q -F "$installedpackageversion" < packageversions/"$packagename" || {
        ui_print "- $packagename $installedpackageversion is not supported."
        return
    }

    ui_print "- Found $packagename $installedpackageversion"

    apkpath=$(pm path "$packagename" | grep -E 'package:.*/base\.apk' | cut -d':' -f2)
    ui_print "- Found YouTube APK at $apkpath"

    apkpath="$MIRROR"/"$apkpath"

    patchAPK "$packagename" "$apkpath"
    
    [ ! -f overlay/"$packagename".apk ] && abort "Couldn't locate patched file!"

    chcon u:object_r:apk_data_file:s0 overlay/"$packagename".apk
}

patchAPK() {
    local packagename="$1"
    local apkpath="$2"
    cd "$TMPDIR"

    ui_print "- Patching $packagename"

    export MODPATH
    "$MODPATH"/system/bin/revancedcli \
        -a "$apkpath" \
        -c \
        -o out.apk \
        -b "$MODPATH"/patches.jar \
        -m "$MODPATH"/integrations.apk \
        -e vanced-microg-support \
        -e music-microg-support \
    2>&1 || abort "Patching failed! $?"

    [ ! -f out.apk ] && abort "Patching failed!"

    mv -v out.apk "$MODPATH"/overlay/"$packagename".apk

    cd "$MODPATH"
}

for packagename in packageversions/*; do
    packagename="$(basename "$packagename")"
    processPackage "$packagename"
done

[ -z "$(ls overlay)" ] && abort "No compatible packages have been found."
