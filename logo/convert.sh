#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

generateImage() {
    local infile="$1"
    local outfile="$2"
    local size="$3"
    mkdir -p "$(dirname "$outfile")"
    convert -density "$(($size * 10))" -antialias -resize "${size}x${size}" -background none "$infile" "$outfile"
}

#image conversion
CONVERSION=(
    logo_standalone.svg:static:ic_launcher.png
    logo_round.svg:static:ic_launcher_round.png
    adaptive_background.svg:adaptive:adaptiveproduct_youtube_background_color_108.png
    adaptive_foreground.svg:adaptive:adaptiveproduct_youtube_foreground_color_108.png
)

rm -rf assets

for image in "${CONVERSION[@]}"; do
    type="$(cut -d':' -f2 <<< "$image")"
    infile="$(cut -d':' -f1 <<< "$image")"
    outfile="$(cut -d':' -f3 <<< "$image")"
    case "$type" in
        adaptive)
        for format in hdpi:162 mdpi:108 xhdpi:216 xxhdpi:324 xxxhdpi:432; do
            outfolder=assets/mipmap-"$(cut -d':' -f1 <<< "$format")"
            size="$(cut -d':' -f2 <<< "$format")"
            generateImage "$infile" "$outfolder"/"$outfile" "$size" &
        done
        ;;
    static)
        for format in hdpi:72 mdpi:48 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
            outfolder=assets/mipmap-"$(cut -d':' -f1 <<< "$format")"
            size="$(cut -d':' -f2 <<< "$format")"
            generateImage "$infile" "$outfolder"/"$outfile" "$size" &
        done
        ;;
    *)
        echo "unknown type $type" >&2
        exit 1
    esac
done
wait
