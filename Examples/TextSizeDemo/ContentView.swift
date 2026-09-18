import ScaledFont
import SwiftUI

/// The text styles of two style dictionaries with SwiftUI, and of
/// one with AppKit, at the text size of the app.

struct ContentView: View {
    private let futura = ScaledFont(fontName: "Futura", bundle: .module)
    private let systemFonts = ScaledFont(fontName: "SystemFonts", bundle: .module)

    var body: some View {
        VStack(spacing: 0) {
            SizeBar()
            Divider()
            HStack(alignment: .top, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        StyleSamples(title: "SwiftUI · Futura.plist")
                            .scaledFont(futura)
                        StyleSamples(title: "SwiftUI · SystemFonts.plist")
                            .scaledFont(systemFonts)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                AppKitSamples(scaledFont: futura)
                    .frame(width: 340)
            }
        }
        .frame(minWidth: 800, minHeight: 560)
    }
}

/// The current text size and buttons that change it.

struct SizeBar: View {
    @EnvironmentObject private var textSize: TextSizePreference

    var body: some View {
        HStack {
            Text("Text size: \(textSize.dynamicTypeSize.displayName)")
            Spacer()
            Button {
                textSize.decrease()
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .disabled(!textSize.canDecrease)
            .help("Make Text Smaller")
            Button("Normal Size") {
                textSize.reset()
            }
            Button {
                textSize.increase()
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .disabled(!textSize.canIncrease)
            .help("Make Text Bigger")
        }
        .padding(8)
    }
}

/// Every text style of the scaled font in the environment.

struct StyleSamples: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Large Title").scaledFont(.largeTitle)
            Text("Title").scaledFont(.title)
            Text("Title 2").scaledFont(.title2)
            Text("Title 3").scaledFont(.title3)
            Text("Headline").scaledFont(.headline)
            Text("Body text wraps onto more lines as the text size grows.").scaledFont(.body)
            Text("Callout").scaledFont(.callout)
            Text("Subheadline").scaledFont(.subheadline)
            Text("Footnote").scaledFont(.footnote)
            Text("Caption").scaledFont(.caption)
            Text("Caption 2").scaledFont(.caption2)
        }
    }
}

extension DynamicTypeSize {
    /// A name for the size in the interface.
    var displayName: String {
        switch self {
        case .xSmall: return "Extra Small"
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large (Default)"
        case .xLarge: return "Extra Large"
        case .xxLarge: return "Extra Extra Large"
        case .xxxLarge: return "Extra Extra Extra Large"
        case .accessibility1: return "Accessibility 1"
        case .accessibility2: return "Accessibility 2"
        case .accessibility3: return "Accessibility 3"
        case .accessibility4: return "Accessibility 4"
        case .accessibility5: return "Accessibility 5"
        @unknown default: return "Unknown"
        }
    }
}
