# Offering an In-App Text Size

Let people choose a larger or smaller text size in your app on macOS, where there is no Dynamic Type.

## Overview

macOS does not share the text size people choose in System Settings with other apps, and SwiftUI ignores the Dynamic Type size for fonts on the Mac. To let people make the text in your app larger, offer your own text size setting. ScaledFont scales the fonts it manages to that size, with the same steps and the same text style hierarchy as Dynamic Type on iOS.

![Text styles of the Futura style dictionary at the Large, Extra Extra Extra Large and Accessibility 3 sizes.](typical-text-sizes)

Apple's [Larger Text evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/larger-text-evaluation-criteria) allow an in-app text size setting in place of the system setting, and ask for text that can grow to at least 200 percent.

### Store the Size

``TextSizePreference`` stores the size in the user defaults of your app, keeps it within a range, and tells your app when it changes. The range includes every accessibility size by default. Narrow it only when a layout cannot show the largest sizes:

```swift
let textSize = TextSizePreference(range: .xSmall ... .accessibility3)
```

### Apply the Size in SwiftUI

Set the size on your view hierarchy with the `dynamicTypeSize(_:)` modifier. The `scaledFont(_:)` modifiers read it and scale their fonts:

```swift
@main
struct ReaderApp: App {
    @StateObject private var textSize = TextSizePreference()
    private let scaledFont = ScaledFont(fontName: "Noteworthy")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .scaledFont(scaledFont)
                .dynamicTypeSize(textSize.dynamicTypeSize)
        }
        .commands {
            CommandGroup(after: .toolbar) {
                Button("Make Text Bigger") { textSize.increase() }
                    .keyboardShortcut("+")
                    .disabled(!textSize.canIncrease)
                Button("Make Text Smaller") { textSize.decrease() }
                    .keyboardShortcut("-")
                    .disabled(!textSize.canDecrease)
                Button("Make Text Normal Size") { textSize.reset() }
                    .keyboardShortcut("0")
            }
        }
    }
}
```

The menu titles and the keyboard shortcuts are an example. Choose the ones that suit your app.

### Apply the Size in AppKit

Pass the size when you get a font, and set the fonts again when the preference changes, because AppKit does not adjust fonts by itself. The preference posts its notification on the main thread:

```swift
func applyFonts() {
    label.font = scaledFont.font(forTextStyle: .body, dynamicTypeSize: textSize.dynamicTypeSize)
}

func observeTextSize() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(textSizeDidChange(_:)),
        name: TextSizePreference.didChangeNotification,
        object: textSize
    )
}

@objc func textSizeDidChange(_ notification: Notification) {
    applyFonts()
}
```

Set the fonts of attributed text, such as the contents of an `NSTextView`, again as well.

### Try the Demo App

The `Examples` folder of the package contains `TextSizeDemo`, a macOS app that changes the text size from the View menu, from the toolbar and from a slider in Settings, for text in SwiftUI and in AppKit. Run `swift run TextSizeDemo` in that folder.

![The TextSizeDemo window at the Extra Extra Extra Large size, with the size in the window subtitle, the toolbar buttons that change it, and the keyboard shortcuts at the bottom.](text-size-demo)

### How Fonts Scale

- A custom font scales from the size in the style dictionary by the factor `UIFontMetrics` applies to it on iOS, and is rounded to whole points the way `UIFontMetrics` rounds, so it has the same size on both platforms.
- A system font scales from the macOS size of its text style by the ratio of the iOS preferred font sizes, is rounded to whole points, and keeps the weight of the text style.
- At `.large`, the fonts are exactly the ones you get without a size, including a style dictionary size such as 17.2 points.

Text styles grow by different amounts, as they do on iOS. At the largest accessibility size, body text grows to almost three times its size while large titles grow much less, so the hierarchy tightens.

On iOS, iPadOS, tvOS and visionOS, ``ScaledFont/ScaledFont/font(forTextStyle:design:weight:dynamicTypeSize:)`` takes an explicit size as well. For that font it replaces the size chosen in the system settings.

### Every Size

Each tab shows every text style at one size on macOS, with the Futura style dictionary on the left and the system font on the right. At Large, the fonts are the ones you get without a size.

@TabNavigator {
    @Tab("xSmall") {
        ![Every text style at the Extra Small size, with Futura on the left and the system font on the right.](text-size-xsmall)
    }

    @Tab("Small") {
        ![Every text style at the Small size, with Futura on the left and the system font on the right.](text-size-small)
    }

    @Tab("Medium") {
        ![Every text style at the Medium size, with Futura on the left and the system font on the right.](text-size-medium)
    }

    @Tab("Large") {
        ![Every text style at the default Large size, with Futura on the left and the system font on the right.](text-size-large)
    }

    @Tab("xLarge") {
        ![Every text style at the Extra Large size, with Futura on the left and the system font on the right.](text-size-xlarge)
    }

    @Tab("xxLarge") {
        ![Every text style at the Extra Extra Large size, with Futura on the left and the system font on the right.](text-size-xxlarge)
    }

    @Tab("xxxLarge") {
        ![Every text style at the Extra Extra Extra Large size, with Futura on the left and the system font on the right.](text-size-xxxlarge)
    }

    @Tab("AX1") {
        ![Every text style at the Accessibility 1 size, with Futura on the left and the system font on the right.](text-size-accessibility1)
    }

    @Tab("AX2") {
        ![Every text style at the Accessibility 2 size, with Futura on the left and the system font on the right.](text-size-accessibility2)
    }

    @Tab("AX3") {
        ![Every text style at the Accessibility 3 size, with Futura on the left and the system font on the right.](text-size-accessibility3)
    }

    @Tab("AX4") {
        ![Every text style at the Accessibility 4 size, with Futura on the left and the system font on the right.](text-size-accessibility4)
    }

    @Tab("AX5") {
        ![Every text style at the Accessibility 5 size, with Futura on the left and the system font on the right.](text-size-accessibility5)
    }
}
