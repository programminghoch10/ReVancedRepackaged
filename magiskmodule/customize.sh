#!/system/bin/sh

#shellcheck disable=SC2154
[ "$BOOTMODE" != "true" ] && abort "Please install this module within the Magisk app."

cd "$MODPATH"

[ ! -f ./version.sh ] && abort "Missing version.sh"
. ./version.sh

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
MIRROR="$MAGISKTMP"/.magisk/mirror
ui_print "- Found Magisk mirror at $MIRROR"

findConfigFile() {
    for path in /storage/emulated/0 /data/adb; do
        [ -f "$path/$1" ] && echo "$path/$1" && break
    done
}

BLACKLIST="$(findConfigFile revancedrepackaged-blacklist.txt)"
[ -n "$BLACKLIST" ] && ui_print "- Found blacklist at $BLACKLIST"

ui_print "- Preparing Patching Process"

[ ! -f aapt2lib/"$ARCH"/libaapt2.so ] && abort "Failed to locate libaapt2.so for $ARCH"
mv -v aapt2lib/"$ARCH"/libaapt2.so aapt2
rm -r aapt2lib
chmod -v +x aapt2

chmod -v +x system/bin/revancedcli

mkdir overlay

processPackage() {
    packagename="$1"

    [ -z "$(pm list packages "$packagename")" ] && return

    grep -q -F "$packagename" < "$BLACKLIST" \
    && ui_print "- Skipping $packagename (blacklisted)" \
    && return

    ui_print "- Processing $packagename"

    installedpackageversion="$(pm dump "$packagename" | grep -E '^ *versionName=.*$' | cut -d'=' -f2)"

    [ -s packageversions/"$packagename" ] \
    && ! grep -q -F "$installedpackageversion" < packageversions/"$packagename" \
    && ui_print "- $packagename $installedpackageversion is not supported." \
    && return

    ui_print "- Found $packagename $installedpackageversion"

    apkpath=$(pm path "$packagename" | grep -E 'package:.*/base\.apk' | cut -d':' -f2)

    [ ! -f "$apkpath" ] \
    && ui_print "  $apkpath provided by package manager doesn't exist!" \
    && return

    ui_print "- Found APK at $apkpath"

    apkpath="$MIRROR"/"$apkpath"

    patchAPK "$packagename" "$apkpath"
    
    [ ! -f overlay/"$packagename".apk ] && abort "Couldn't locate patched file!"
    sha256sum < "$apkpath" > overlay/"$packagename".sha256sum

    chcon u:object_r:apk_data_file:s0 overlay/"$packagename".apk
}

patchAPK() {
    packagename="$1"
    apkpath="$2"
    cd "$TMPDIR"

    ui_print "- Patching $packagename"
    
    cp "$MODPATH"/options.json options.json

    [ -f "$MODPATH"/options/"$packagename".json ] \
        && cp "$MODPATH"/options/"$packagename".json options.json
    
    optionsconfigfile="$(findConfigFile revancedrepackaged-options.json)"
    [ -f "$optionsconfigfile" ] \
        && cp "$optionsconfigfile" options.json

    sed -i "s|\$MODPATH|$MODPATH|g" options.json

    export MODPATH
    "$MODPATH"/system/bin/revancedcli \
        patch \
        --patch-bundle="$MODPATH"/patches.jar \
        --merge="$MODPATH"/integrations.apk \
        --out=out.apk \
        --exclude='GmsCore support' \
        --include='Custom branding' \
        --options=options.json \
        --purge \
        "$apkpath" \
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
