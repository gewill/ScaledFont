# Choosing Font Variants

Use a serif or monospaced system font, or a bold weight, from the style dictionary or where you use the font.

## Overview

ScaledFont supports two font variants:

- term Design: The design of a system font, which is ``ScaledFont/ScaledFont/FontDesign/default``, ``ScaledFont/ScaledFont/FontDesign/serif`` or ``ScaledFont/ScaledFont/FontDesign/monospaced``.
- term Weight: The weight of the font, which is ``ScaledFont/ScaledFont/FontWeight/regular`` or ``ScaledFont/ScaledFont/FontWeight/bold``.

A design only applies to a system font, which is a text style whose entry in the style dictionary has no `fontName`. A weight applies to both system fonts and custom fonts.

### Set Variants in the Style Dictionary

Use the `design` and `weight` keys in the entry for a text style. This entry uses a bold, serif system font for the `.subheadline` style:

```
<dict>
  <key>subheadline</key>
  <dict>
    <key>design</key>
    <string>serif</string>
    <key>weight</key>
    <string>bold</string>
  </dict>
</dict>
```

See <doc:StyleDictionary> for the other keys.

### Override Variants Where You Use a Font

Pass a design or a weight when you get the font. A variant that you pass takes precedence over the style dictionary, and passing `nil` keeps the variant from the style dictionary:

```swift
// UIKit or AppKit
label.font = scaledFont.font(forTextStyle: .body, design: .monospaced)

// SwiftUI
Text("Metadata")
    .scaledFont(.subheadline, design: .serif, weight: .bold)
```

Use ``ScaledFont/ScaledFont/FontDesign/default`` or ``ScaledFont/ScaledFont/FontWeight/regular`` to undo a variant that the style dictionary sets.

### Make a Custom Font Bold

For a custom font, the `bold` weight uses the bold face of the same font family when the family has one that keeps the other style traits, such as italic or condensed. A font that is already bold stays as it is, and so does a font whose family has no matching bold face. For example, in the Futura family `Futura-Medium` becomes `Futura-Bold`, while `Futura-MediumItalic` stays as it is because the family has no bold italic face.

### Check Availability

The `serif` and `monospaced` designs need iOS 13, tvOS 13, watchOS 7 or macOS 11 or later, and are ignored on earlier versions. A design or a weight that ScaledFont does not support is ignored as well, and the font uses the normal system design or weight.

### Handle New Variants

``ScaledFont/ScaledFont/FontDesign`` and ``ScaledFont/ScaledFont/FontWeight`` are structures rather than enumerations, so that new designs and weights can be added without breaking your code. Include a `default` case when you switch over them:

```swift
func label(for design: ScaledFont.FontDesign) -> String {
    switch design {
    case .serif: return "Serif"
    case .monospaced: return "Monospaced"
    default: return "Default"
    }
}
```

A style dictionary that names a value this version of ScaledFont does not know still loads, and that value is ignored.
