# Using a Scaled Font

Create a scaled font from a style dictionary and apply it to the text in your app.

## Overview

Create one `ScaledFont` for each style dictionary and share it across your app. Add the style dictionary to your app target, along with the font files of any custom font it uses:

```swift
let scaledFont = ScaledFont(fontName: "Noteworthy")
```

By default ``ScaledFont/ScaledFont/init(fontName:bundle:)`` looks for the style dictionary in the main bundle. Pass the bundle that contains it when you keep the style dictionary in a framework or a Swift package. If the style dictionary can't be found or isn't valid, every text style uses the system font.

To change the design or the weight of a font where you use it, see <doc:FontVariants>.

### Use a Scaled Font With UIKit

Set the font of a label, text field or text view with ``ScaledFont/ScaledFont/font(forTextStyle:)``, and set `adjustsFontForContentSizeCategory` so that the text updates when someone changes their preferred text size:

```swift
let label = UILabel()
label.font = scaledFont.font(forTextStyle: .headline)
label.adjustsFontForContentSizeCategory = true
```

The UIKit API needs iOS 11, tvOS 11 or watchOS 4 or later.

### Use a Scaled Font With AppKit

On macOS, ``ScaledFont/ScaledFont/font(forTextStyle:)`` takes an `NSFont.TextStyle` and returns an `NSFont`:

```swift
let textField = NSTextField(labelWithString: "Headline")
textField.font = scaledFont.font(forTextStyle: .headline)
```

macOS does not have Dynamic Type, so a custom font keeps the size from the style dictionary, and a text style without an entry uses the macOS system font for that style. The AppKit API needs macOS 11 or later. To let people choose a text size in your app, see <doc:InAppTextSize>.

### Use a Scaled Font With SwiftUI

Add the scaled font to the environment of a view, typically the root of your view hierarchy:

```swift
ContentView()
    .scaledFont(scaledFont)
```

Then apply the scaled font to any view that contains text:

```swift
Text("Headline")
    .scaledFont(.headline)
```

On platforms with Dynamic Type, SwiftUI scales the font as the text size changes. On macOS 12 and later the font follows the `dynamicTypeSize` of the environment instead, which your app sets; see <doc:InAppTextSize>. The SwiftUI API needs iOS 13, tvOS 13, watchOS 6 or macOS 11 or later.

> Note: Depending on the OS version, a view presented in a sheet may not inherit the environment of the presenting view. Passing the scaled font on explicitly works everywhere:

```swift
struct ContentView: View {
    @Environment(\.scaledFont) private var scaledFont
    @State private var isShowingSheet = false

    var body: some View {
        Button("Present View") {
            isShowingSheet = true
        }
        .sheet(isPresented: $isShowingSheet) {
            SheetView()
                .scaledFont(scaledFont)
        }
    }
}
```
