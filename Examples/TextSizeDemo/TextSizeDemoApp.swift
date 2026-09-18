import AppKit
import ScaledFont
import SwiftUI

/// A macOS app that shows the in-app text size of ScaledFont.
///
/// Change the size with the View menu, the toolbar, or the slider
/// in Settings. Text that uses a scaled font grows, while the rest
/// of the interface keeps its size, as it does in any Mac app.

@main
struct TextSizeDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var textSize = TextSizePreference()

    var body: some Scene {
        WindowGroup("ScaledFont Text Size") {
            ContentView()
                .environmentObject(textSize)
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

        Settings {
            SettingsView()
                .environmentObject(textSize)
        }
    }
}

/// Brings the app to the front, because `swift run` starts it
/// without an app bundle.

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
