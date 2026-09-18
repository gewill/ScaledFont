# Examples

## Style Dictionaries

| File | Font |
| --- | --- |
| `Futura.plist` | Futura, which is built into iOS, tvOS, watchOS and macOS. |
| `Noteworthy.plist` | Noteworthy, which is built into iOS and macOS. |
| `NotoSerif.plist` | Noto Serif, which you download from [Google Fonts](https://fonts.google.com/specimen/Noto+Serif) and add to your app. |
| `SystemFonts.plist` | No custom font: the system font with the serif and monospaced designs and a bold weight. |

Add a style dictionary to your app target, along with the font files of any custom font it uses, and create a `ScaledFont` with its name, for example `ScaledFont(fontName: "Futura")`.

**Check the license for any fonts you plan on shipping with your application.**

## TextSizeDemo

A macOS app that shows the in-app text size. Change the size with the View menu (⌘+, ⌘- and ⌘0), the toolbar, or the slider in Settings; the window subtitle shows the current size. The window shows `Futura.plist` and `SystemFonts.plist` with SwiftUI, and `Futura.plist` with AppKit.

The app needs macOS 12 or later. Run it from this folder:

```sh
swift run TextSizeDemo
```

The app stores the chosen size in its user defaults, so it opens at the same size the next time.

## Documentation Images

`Tools/update-doc-images.sh` renders the images in the documentation catalog of the package, which the README of the package shows as well. Run it after a change to the text styles, the scaling of the fonts or the demo, on macOS 13 or later:

```sh
Tools/update-doc-images.sh
```

It writes a light and a dark version of each image into `Sources/ScaledFont/ScaledFont.docc/Resources`:

- `text-size-<size>`, `typical-text-sizes` and `example-style-dictionaries` show the text styles of `Futura.plist`, `SystemFonts.plist` and the system font. The `DocImages` target of this package renders them.
- `text-size-demo` is the TextSizeDemo window at the Extra Extra Extra Large size, which the app saves when it starts with `--screenshot <file>`. The demo opens for a few seconds, once for each appearance, and the text size and the window frame that it stores stay the same.

The images depend on the fonts and the version of macOS that render them, and the demo window on the display as well. On the same Mac and display, an image that did not change comes out byte for byte the same, so git shows only the images that changed.
