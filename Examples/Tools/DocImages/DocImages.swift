import AppKit
import ScaledFont
import SwiftUI

/// Renders images for the documentation catalog of ScaledFont into the
/// folder given as the argument, in light and dark versions:
///
/// - `text-size-<size>`: every text style at one text size, with the
///   Futura style dictionary and with the system font.
/// - `typical-text-sizes`: Futura at three typical text sizes.
/// - `example-style-dictionaries`: the Futura and SystemFonts style
///   dictionaries at the default text size.
///
/// `Tools/update-doc-images.sh` runs it.

@main
enum DocImages {
    @MainActor
    static func main() {
        guard CommandLine.arguments.count == 2 else {
            fail("Usage: DocImages <output folder>")
        }
        guard #available(macOS 13.0, *) else {
            fail("DocImages needs macOS 13 or later.")
        }
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let futura = ScaledFont(fontName: "Futura", bundle: .module)
        let systemFonts = ScaledFont(fontName: "SystemFonts", bundle: .module)
        // Without a style dictionary, every text style uses the system font.
        let system = ScaledFont(fontName: "NoStyleDictionary", bundle: .module)

        for size in Samples.sizes {
            render(EverySize(size: size, futura: futura, system: system), named: "text-size-\(size.slug)", to: folder)
        }
        render(TypicalSizes(futura: futura), named: "typical-text-sizes", to: folder)
        render(ExampleDictionaries(futura: futura, systemFonts: systemFonts), named: "example-style-dictionaries", to: folder)
    }

    /// Writes a light and a dark image at twice the size in points, the
    /// way the documentation catalog names them.
    @available(macOS 13.0, *)
    @MainActor
    static func render<Content: View>(_ content: Content, named name: String, to folder: URL) {
        for (suffix, colorScheme) in [("", ColorScheme.light), ("~dark", ColorScheme.dark)] {
            let renderer = ImageRenderer(content: content.environment(\.colorScheme, colorScheme))
            renderer.scale = 2
            let url = folder.appendingPathComponent("\(name)\(suffix)@2x.png")
            guard let image = renderer.cgImage,
                  let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
            else {
                fail("Could not render \(url.lastPathComponent)")
            }
            do {
                try data.write(to: url)
            } catch {
                fail("Could not write \(url.path): \(error.localizedDescription)")
            }
            print("\(url.lastPathComponent): \(image.width) x \(image.height) pixels")
        }
    }

    static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("\(message)\n".utf8))
        exit(1)
    }
}

enum Samples {
    struct Size {
        let slug: String
        let name: String
        let dynamicTypeSize: DynamicTypeSize
    }

    static let styles: [(name: String, style: Font.TextStyle)] = [
        ("Large Title", .largeTitle), ("Title", .title), ("Title 2", .title2), ("Title 3", .title3),
        ("Headline", .headline), ("Body", .body), ("Callout", .callout), ("Subheadline", .subheadline),
        ("Footnote", .footnote), ("Caption", .caption), ("Caption 2", .caption2)
    ]

    static let sizes: [Size] = [
        Size(slug: "xsmall", name: "Extra Small", dynamicTypeSize: .xSmall),
        Size(slug: "small", name: "Small", dynamicTypeSize: .small),
        Size(slug: "medium", name: "Medium", dynamicTypeSize: .medium),
        Size(slug: "large", name: "Large (Default)", dynamicTypeSize: .large),
        Size(slug: "xlarge", name: "Extra Large", dynamicTypeSize: .xLarge),
        Size(slug: "xxlarge", name: "Extra Extra Large", dynamicTypeSize: .xxLarge),
        Size(slug: "xxxlarge", name: "Extra Extra Extra Large", dynamicTypeSize: .xxxLarge),
        Size(slug: "accessibility1", name: "Accessibility 1", dynamicTypeSize: .accessibility1),
        Size(slug: "accessibility2", name: "Accessibility 2", dynamicTypeSize: .accessibility2),
        Size(slug: "accessibility3", name: "Accessibility 3", dynamicTypeSize: .accessibility3),
        Size(slug: "accessibility4", name: "Accessibility 4", dynamicTypeSize: .accessibility4),
        Size(slug: "accessibility5", name: "Accessibility 5", dynamicTypeSize: .accessibility5)
    ]
}

struct Caption: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

/// Every text style, named after itself.
struct StyleColumn: View {
    let title: String
    let scaledFont: ScaledFont

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Caption(text: title)
                .padding(.bottom, 4)
            ForEach(Samples.styles, id: \.name) { sample in
                Text(sample.name)
                    .scaledFont(sample.style)
                    .foregroundStyle(.primary)
            }
        }
        .scaledFont(scaledFont)
        .frame(width: 380, alignment: .topLeading)
    }
}

struct EverySize: View {
    let size: Samples.Size
    let futura: ScaledFont
    let system: ScaledFont

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(size.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
            HStack(alignment: .top, spacing: 24) {
                StyleColumn(title: "Futura.plist, a custom font", scaledFont: futura)
                StyleColumn(title: "No style dictionary, the system font", scaledFont: system)
            }
        }
        .padding(20)
        .dynamicTypeSize(size.dynamicTypeSize)
    }
}

struct TypicalSizes: View {
    let futura: ScaledFont

    private let sizes: [(name: String, dynamicTypeSize: DynamicTypeSize)] = [
        ("Large (Default)", .large), ("Extra Extra Extra Large", .xxxLarge), ("Accessibility 3", .accessibility3)
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 28) {
            ForEach(sizes, id: \.name) { size in
                VStack(alignment: .leading, spacing: 4) {
                    Caption(text: size.name)
                        .padding(.bottom, 4)
                    Text("Large Title").scaledFont(.largeTitle)
                    Text("Headline").scaledFont(.headline)
                    Text("Body text").scaledFont(.body)
                    Text("Caption").scaledFont(.caption)
                }
                .foregroundStyle(.primary)
                .scaledFont(futura)
                .dynamicTypeSize(size.dynamicTypeSize)
                .frame(width: 280, alignment: .topLeading)
            }
        }
        .padding(20)
    }
}

struct ExampleDictionaries: View {
    let futura: ScaledFont
    let systemFonts: ScaledFont

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            StyleColumn(title: "Futura.plist", scaledFont: futura)
            StyleColumn(title: "SystemFonts.plist", scaledFont: systemFonts)
        }
        .padding(20)
    }
}
