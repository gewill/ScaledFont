import ScaledFont
import SwiftUI

/// A slider over the sizes people can choose, and a switch for the
/// accessibility sizes, like the text size settings on iOS.

struct SettingsView: View {
    @EnvironmentObject private var textSize: TextSizePreference

    var body: some View {
        Form {
            Slider(value: position, in: 0...Double(sizes.count - 1), step: 1) {
                Text("Text size")
            } minimumValueLabel: {
                Image(systemName: "textformat.size.smaller")
            } maximumValueLabel: {
                Image(systemName: "textformat.size.larger")
            }
            Text(textSize.dynamicTypeSize.displayName)
                .foregroundStyle(.secondary)
            Toggle("Larger accessibility sizes", isOn: includesAccessibilitySizes)
        }
        .padding(20)
        .frame(width: 440)
    }

    /// The sizes within the range of the preference.
    private var sizes: [DynamicTypeSize] {
        DynamicTypeSize.allCases.filter { textSize.range.contains($0) }
    }

    private var position: Binding<Double> {
        Binding(
            get: { Double(sizes.firstIndex(of: textSize.dynamicTypeSize) ?? 0) },
            set: { textSize.dynamicTypeSize = sizes[Int($0.rounded())] }
        )
    }

    /// Narrowing the range clamps the current size into it.
    private var includesAccessibilitySizes: Binding<Bool> {
        Binding(
            get: { textSize.range.upperBound > .xxxLarge },
            set: { textSize.range = .xSmall ... ($0 ? .accessibility5 : .xxxLarge) }
        )
    }
}
