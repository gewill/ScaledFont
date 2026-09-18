import AppKit
import ScaledFont
import SwiftUI

/// Labels whose fonts come from the AppKit API of ScaledFont.
///
/// AppKit does not adjust fonts by itself, so the view controller
/// sets them again when the text size preference changes.

final class AppKitSampleViewController: NSViewController {
    private let scaledFont: ScaledFont
    private let textSize: TextSizePreference
    private let samples: [(NSFont.TextStyle, NSTextField)] = [
        (.largeTitle, NSTextField(labelWithString: "Large Title")),
        (.headline, NSTextField(labelWithString: "Headline")),
        (.body, NSTextField(wrappingLabelWithString: "Body text in an NSTextField wraps onto more lines as the text size grows.")),
        (.caption1, NSTextField(labelWithString: "Caption"))
    ]

    init(scaledFont: ScaledFont, textSize: TextSizePreference) {
        self.scaledFont = scaledFont
        self.textSize = textSize
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let title = NSTextField(labelWithString: "AppKit · Futura.plist")
        title.font = .preferredFont(forTextStyle: .caption1)
        title.textColor = .secondaryLabelColor

        let stack = NSStackView(views: [title] + samples.map { $0.1 })
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor)
        ])
        view = container

        applyFonts()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textSizeDidChange(_:)),
            name: TextSizePreference.didChangeNotification,
            object: textSize
        )
    }

    @objc private func textSizeDidChange(_ notification: Notification) {
        applyFonts()
    }

    private func applyFonts() {
        for (textStyle, label) in samples {
            label.font = scaledFont.font(forTextStyle: textStyle, dynamicTypeSize: textSize.dynamicTypeSize)
        }
    }
}

/// Puts the AppKit labels into the SwiftUI window.

struct AppKitSamples: NSViewControllerRepresentable {
    @EnvironmentObject private var textSize: TextSizePreference
    let scaledFont: ScaledFont

    func makeNSViewController(context: Context) -> AppKitSampleViewController {
        AppKitSampleViewController(scaledFont: scaledFont, textSize: textSize)
    }

    func updateNSViewController(_ viewController: AppKitSampleViewController, context: Context) {}
}
