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

A macOS app that shows the in-app text size. Change the size with the View menu (⌘+, ⌘- and ⌘0), the buttons at the top of the window, or the slider in Settings. The window shows `Futura.plist` and `SystemFonts.plist` with SwiftUI, and `Futura.plist` with AppKit.

The app needs macOS 12 or later. Run it from this folder:

```sh
swift run TextSizeDemo
```

The app stores the chosen size in its user defaults, so it opens at the same size the next time.
