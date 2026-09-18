# Creating A Style Dictionary

Create a style dictionary to control how a custom font scales with dynamic type content size.

## Overview

A style dictionary collects the base font metrics for each of the dynamic type text styles. You need to create a style dictionary for each custom font you want to use in your app.

A style dictionary is a property list file that you include with your app. Add an entry for each text style. The available text styles are:

- `largeTitle`, `title`, `title2`, `title3`
-  `headline`, `subheadline`, `body`, `callout`
-  `footnote`, `caption`, `caption2`

For a custom font, the value of each entry is a dictionary with two keys:

+ `fontName`: A `String` which is the font name.
+ `fontSize`: A number which is the point size to use at the `.large` (base) content size.

If you're not sure which font sizes to use for each style, refer to the specifications in the typography section of the [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography#Specifications). They list the sizes Apple uses for the system font on each platform.

For example, to use a 17 pt Noteworthy-Bold font for the `.headline` style at the `.large` content size:

```
<dict>
  <key>headline</key>
  <dict>
    <key>fontName</key>
    <string>Noteworthy-Bold</string>
    <key>fontSize</key>
    <integer>17</integer>
  </dict>
</dict>
```

For a system font, omit `fontName` and `fontSize` and use the optional variant keys:

+ `design`: `default`, `serif` or `monospaced`
+ `weight`: `regular` or `bold`

For example, to use a serif system font for the `.subheadline` style:

```
<dict>
  <key>subheadline</key>
  <dict>
    <key>design</key>
    <string>serif</string>
  </dict>
</dict>
```

Unsupported variant values are ignored and the normal system font is used. A
custom font entry needs both `fontName` and `fontSize`; if either one is
missing the whole style dictionary is ignored.

You can also override the variants where you use the font, and the `weight`
key works for custom fonts too. See <doc:FontVariants>.

You do not need to include an entry for every text style but if you try to use a text style that is not included in the dictionary it will fallback to the system preferred font.

### Finding Font Names

If you are not sure what font names to use you can print all available names with this code snippet:

```swift
let families = UIFont.familyNames
families.sorted().forEach {
  print("\($0)")
  let names = UIFont.fontNames(forFamilyName: $0)
  print(names)
}
```

On macOS, list the font families and their fonts with `NSFontManager`:

```swift
let manager = NSFontManager.shared
manager.availableFontFamilies.sorted().forEach { family in
  print(family)
  let names = manager.availableMembers(ofFontFamily: family)?.compactMap { $0.first as? String } ?? []
  print(names)
}
```

**The fonts installed with the system are not the same on every platform.**

### Example Style Dictionaries

See the `Examples` folder included in this package for some examples. The `Futura` font is available on iOS, tvOS, watchOS and macOS.

The `SystemFonts` style dictionary uses no custom font. It sets the serif and monospaced designs and a bold weight for the system font.

![Every text style of the Futura style dictionary on the left and of the SystemFonts style dictionary on the right.](example-style-dictionaries)

The `Noteworthy` style dictionary uses a font built into iOS and macOS.

![Noteworthy font](noteworthy)

To use the `NotoSerif` example you'll need to download the font files from [Google fonts](https://fonts.google.com/specimen/Noto+Serif), add them to your application target, and list them under "Fonts provided by application" in the `Info.plist` file of the target.

![Noto Serif font](noto)

**Check the license for any fonts you plan on shipping with your application.**
