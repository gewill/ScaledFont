# ``ScaledFont``

Use custom fonts that scale with Dynamic Type in UIKit, AppKit and SwiftUI.

## Overview

Dynamic Type lets people choose the text size they prefer. Fully supporting it with a custom font takes two steps:

1. Choose a base font, with a suitable weight and size, for each text style at the default Large content size.
2. Scale each base font across the range of Dynamic Type content sizes.

Doing both for every text style spreads font metrics throughout an app, which makes them hard to maintain and hard to keep consistent when the design changes. `ScaledFont` collects the base font for each text style into a **style dictionary**, a property list file that you add to your app, and gives you the scaled font for a text style wherever you need it.

A style dictionary entry can also describe a system font instead of a custom font, with a serif or monospaced design or a bold weight, and you can override those variants where you use the font.

ScaledFont works on iOS, iPadOS, tvOS, watchOS, visionOS and macOS. macOS does not have Dynamic Type, so a custom font there keeps the size from the style dictionary.

## Topics

### Essentials

- <doc:StyleDictionary>
- <doc:UsingAScaledFont>
- ``ScaledFont/ScaledFont``

### Font Variants

- <doc:FontVariants>

### SwiftUI

- ``SwiftUICore/View/scaledFont(_:)-(ScaledFont)``
- ``SwiftUICore/View/scaledFont(_:)-(Font.TextStyle)``
- ``SwiftUICore/View/scaledFont(_:design:weight:)``
- ``SwiftUICore/EnvironmentValues/scaledFont``
