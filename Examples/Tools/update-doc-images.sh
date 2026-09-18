#!/bin/sh
#
# Renders the images in the documentation catalog of ScaledFont, which
# the README shows as well: every text style at every text size, the
# example style dictionaries and the TextSizeDemo window, each in a
# light and a dark version. Run it from any folder, on macOS 13 or later:
#
#     Examples/Tools/update-doc-images.sh
#
# The demo opens for a few seconds, once for each appearance.

set -eu

cd "$(dirname "$0")/.."
resources=../Sources/ScaledFont/ScaledFont.docc/Resources

swift build
bin=$(swift build --show-bin-path)

"$bin/DocImages" "$resources"

# -ScaledFontTextSize opens the demo at a text size for this launch
# only. The size the demo stores does not change.
"$bin/TextSizeDemo" -ScaledFontTextSize xxxLarge --screenshot "$resources/text-size-demo@2x.png"
"$bin/TextSizeDemo" -ScaledFontTextSize xxxLarge --screenshot "$resources/text-size-demo~dark@2x.png" --dark
