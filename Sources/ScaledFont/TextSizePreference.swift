//  Copyright © 2021 Keith Harrison. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

import Combine
import Foundation
import SwiftUI

/// A text size that people choose in the app.
///
/// macOS has no Dynamic Type, so an app whose text should grow
/// offers its own text size setting. `TextSizePreference` stores
/// that setting, keeps it within a range, and tells the app when
/// it changes:
///
/// - SwiftUI observes it as an `ObservableObject`. Apply the size
///   to the view hierarchy with the `dynamicTypeSize(_:)` modifier.
/// - AppKit observes ``didChangeNotification`` and sets the fonts
///   of its views again.
///
/// ```swift
/// @StateObject private var textSize = TextSizePreference()
///
/// var body: some Scene {
///     WindowGroup {
///         ContentView()
///             .scaledFont(scaledFont)
///             .dynamicTypeSize(textSize.dynamicTypeSize)
///     }
/// }
/// ```

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
public final class TextSizePreference: ObservableObject {
    /// Posted on the main thread after the text size changes. The
    /// object of the notification is the preference.
    public nonisolated static var didChangeNotification: Notification.Name {
        Notification.Name("TextSizePreferenceDidChange")
    }

    /// The text size.
    ///
    /// A size outside ``range`` is clamped into it. Assigning the
    /// current size again does nothing: observers are not told
    /// and no notification is posted.
    public var dynamicTypeSize: DynamicTypeSize {
        get { size }
        set { apply(size: newValue, range: allowedRange) }
    }

    /// The sizes people can choose from.
    ///
    /// Narrowing the range clamps the current size into it.
    public var range: ClosedRange<DynamicTypeSize> {
        get { allowedRange }
        set { apply(size: size, range: newValue) }
    }

    /// Whether ``increase()`` can make the text larger.
    public var canIncrease: Bool {
        size < allowedRange.upperBound
    }

    /// Whether ``decrease()`` can make the text smaller.
    public var canDecrease: Bool {
        size > allowedRange.lowerBound
    }

    private var size: DynamicTypeSize
    private var allowedRange: ClosedRange<DynamicTypeSize>
    private let userDefaults: UserDefaults
    private let key: String

    /// Create a text size preference that is stored in the user
    /// defaults of the app.
    ///
    /// - Parameter range: The sizes people can choose from. The
    ///   default includes every accessibility size; narrow it only
    ///   when a layout cannot show the largest sizes.
    /// - Parameter userDefaults: The user defaults that store the
    ///   size. Default is the standard user defaults.
    /// - Parameter key: The key the size is stored under.
    ///
    /// - Note: A missing or unknown stored size starts at `.large`,
    ///   clamped into the range.

    public init(
        range: ClosedRange<DynamicTypeSize> = .xSmall ... .accessibility5,
        userDefaults: UserDefaults = .standard,
        key: String = "ScaledFontTextSize"
    ) {
        let stored = userDefaults.string(forKey: key).flatMap(DynamicTypeSize.init(storageName:)) ?? .large
        self.allowedRange = range
        self.size = stored.clamped(to: range)
        self.userDefaults = userDefaults
        self.key = key
    }

    /// Make the text one size larger, if the range allows it.

    public func increase() {
        move(by: 1)
    }

    /// Make the text one size smaller, if the range allows it.

    public func decrease() {
        move(by: -1)
    }

    /// Return to the default Large size, clamped into the range.

    public func reset() {
        dynamicTypeSize = .large
    }

    private func move(by offset: Int) {
        let sizes = DynamicTypeSize.allCases
        guard let index = sizes.firstIndex(of: size), sizes.indices.contains(index + offset) else {
            return
        }

        dynamicTypeSize = sizes[index + offset]
    }

    private func apply(size newSize: DynamicTypeSize, range newRange: ClosedRange<DynamicTypeSize>) {
        let clamped = newSize.clamped(to: newRange)
        let sizeChanged = clamped != size
        guard sizeChanged || newRange != allowedRange else {
            return
        }

        objectWillChange.send()
        allowedRange = newRange
        size = clamped

        if sizeChanged {
            if let name = clamped.storageName {
                userDefaults.set(name, forKey: key)
            }
            NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension DynamicTypeSize {
    static let storageNames = [
        "xSmall", "small", "medium", "large", "xLarge", "xxLarge", "xxxLarge",
        "accessibility1", "accessibility2", "accessibility3", "accessibility4", "accessibility5"
    ]

    /// The name the size is stored under.
    var storageName: String? {
        scalingStep.map { Self.storageNames[$0] }
    }

    init?(storageName: String) {
        guard let step = Self.storageNames.firstIndex(of: storageName),
              let size = Self.allCases.first(where: { $0.scalingStep == step })
        else {
            return nil
        }

        self = size
    }

    func clamped(to range: ClosedRange<DynamicTypeSize>) -> DynamicTypeSize {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
