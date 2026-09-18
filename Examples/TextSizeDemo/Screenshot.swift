import AppKit

/// Saves an image of the window and quits, when the app starts with
/// `--screenshot <file>`. Add `--dark` for the dark appearance.
///
/// `Tools/update-doc-images.sh` uses it for the documentation of the
/// package. The app draws the window into the image itself, so it
/// does not need permission to record the screen.

@MainActor
enum Screenshot {
    /// The size of the window in the image, in points.
    static let windowSize = NSSize(width: 900, height: 612)

    static func takeIfRequested() {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: "--screenshot"), index + 1 < arguments.count else {
            return
        }
        let url = URL(fileURLWithPath: arguments[index + 1])
        NSApp.appearance = NSAppearance(named: arguments.contains("--dark") ? .darkAqua : .aqua)

        Task {
            guard let window = await openWindow() else {
                fail("The window did not open.")
            }
            let frame = window.frame
            window.setFrame(
                NSRect(x: frame.minX, y: frame.maxY - windowSize.height, width: windowSize.width, height: windowSize.height),
                display: true
            )
            // Let SwiftUI lay out the window at its new size, and the
            // scroll bars that appear with the window fade out.
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            save(window, to: url)
            // Put the window back, so that the app opens it where it was
            // the next time.
            window.setFrame(frame, display: false)
            NSApp.terminate(nil)
        }
    }

    private static func openWindow() async -> NSWindow? {
        for _ in 0..<50 {
            if let window = NSApp.windows.first(where: { $0.isVisible && $0.canBecomeMain }) {
                return window
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        return nil
    }

    /// Draws the window with its title bar and toolbar, at twice its
    /// size in points.
    private static func save(_ window: NSWindow, to url: URL) {
        guard window.backingScaleFactor == 2 else {
            fail("The window needs to be on a Retina display.")
        }
        guard let frameView = window.contentView?.superview,
              let drawing = frameView.bitmapImageRepForCachingDisplay(in: frameView.bounds)
        else {
            fail("Could not draw the window.")
        }
        frameView.cacheDisplay(in: frameView.bounds, to: drawing)
        // Convert from the color space of the display, so that the image
        // does not carry the color profile of the display.
        guard let image = drawing.converting(to: .sRGB, renderingIntent: .default),
              let data = image.representation(using: .png, properties: [:])
        else {
            fail("Could not make a PNG image of the window.")
        }
        do {
            try data.write(to: url)
        } catch {
            fail("Could not write \(url.path): \(error.localizedDescription)")
        }
        print("\(url.lastPathComponent): \(image.pixelsWide) x \(image.pixelsHigh) pixels")
    }

    private static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("\(message)\n".utf8))
        exit(1)
    }
}
