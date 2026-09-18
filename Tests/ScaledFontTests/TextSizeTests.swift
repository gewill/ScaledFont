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

@testable import ScaledFont
import Combine
import SwiftUI
import XCTest
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private let styleKeys: [ScaledFont.StyleKey] = [
    .largeTitle, .title, .title2, .title3, .headline, .subheadline,
    .body, .callout, .footnote, .caption, .caption2
]

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class TextSizeScalingTests: XCTestCase {
    func testTablesCoverEveryStyleAndSize() {
        for key in styleKeys {
            XCTAssertEqual(TextSizeScaling.systemPointSizes[key]?.count, 12, "\(key)")
            XCTAssertEqual(TextSizeScaling.customFontMultipliers[key]?.count, 12, "\(key)")
            XCTAssertEqual(TextSizeScaling.systemFontScale(for: key, step: TextSizeScaling.largeStep), 1, "\(key)")
            XCTAssertEqual(TextSizeScaling.customFontScale(for: key, step: TextSizeScaling.largeStep), 1, "\(key)")
        }
    }

    func testEverySizeHasItsOwnStep() {
        XCTAssertEqual(DynamicTypeSize.allCases.map(\.scalingStep), (0...11).map { Optional($0) })
    }

    func testScalesNeverShrinkAsTheSizeGrows() {
        for key in styleKeys {
            for step in 1..<12 {
                XCTAssertGreaterThanOrEqual(
                    TextSizeScaling.systemFontScale(for: key, step: step),
                    TextSizeScaling.systemFontScale(for: key, step: step - 1),
                    "\(key) step \(step)"
                )
                XCTAssertGreaterThanOrEqual(
                    TextSizeScaling.customFontScale(for: key, step: step),
                    TextSizeScaling.customFontScale(for: key, step: step - 1),
                    "\(key) step \(step)"
                )
            }
        }
    }

    private let scales: [(kind: String, scale: (ScaledFont.StyleKey, Int) -> CGFloat)] = [
        ("custom", TextSizeScaling.customFontScale(for:step:)),
        ("system", TextSizeScaling.systemFontScale(for:step:))
    ]

    private func scaledSizes(_ size: CGFloat, _ key: ScaledFont.StyleKey, _ scale: (ScaledFont.StyleKey, Int) -> CGFloat) -> [CGFloat] {
        (0..<12).map { TextSizeScaling.scaledSize(size, by: scale(key, $0), step: $0) }
    }

    /// A larger size never gets a smaller font for any size at
    /// Large from 6 to 100 points, in steps of 0.01 point, although
    /// the size at Large keeps its fraction and the others are
    /// rounded.

    func testScaledSizesNeverShrinkAsTheSizeGrows() {
        for key in styleKeys {
            for (kind, scale) in scales {
                let shrinking = (600...10_000).map { CGFloat($0) / 100 }.filter { size in
                    let sizes = scaledSizes(size, key, scale)
                    return zip(sizes, sizes.dropFirst()).contains { $1 < $0 }
                }
                XCTAssertTrue(shrinking.isEmpty, "\(kind) \(key): \(shrinking.prefix(5))")
            }
        }
    }

    /// A whole point size at Large gets the rounded sizes, as on
    /// iOS.

    func testWholePointSizesAreRounded() {
        for key in styleKeys {
            for (kind, scale) in scales {
                let differing = (6...100).map { CGFloat($0) }.filter { size in
                    scaledSizes(size, key, scale) != (0..<12).map { (size * scale(key, $0)).rounded() }
                }
                XCTAssertTrue(differing.isEmpty, "\(kind) \(key): \(differing.prefix(5))")
            }
        }
    }

    /// A size that rounding would take past the size at Large keeps
    /// the size at Large instead.

    func testRoundingDoesNotPassAFractionalSizeAtLarge() {
        let custom = TextSizeScaling.customFontScale(for:step:)
        // Rounding gives 18 points up to medium, more than 17.8.
        XCTAssertEqual(scaledSizes(17.8, .caption2, custom), [17.8, 17.8, 17.8, 17.8, 25, 27, 30, 34, 40, 48, 56, 66])
        // Both sides of a half point.
        XCTAssertEqual(scaledSizes(11.49, .caption2, custom).prefix(4), [11, 11, 11, 11.49])
        XCTAssertEqual(scaledSizes(11.5, .caption2, custom).prefix(4), [11.5, 11.5, 11.5, 11.5])
        // Rounding gives 9 points at xLarge, less than 9.05.
        XCTAssertEqual(scaledSizes(9.05, .largeTitle, custom)[3...4], [9.05, 9.05])
    }

    #if os(iOS) && !targetEnvironment(macCatalyst)
    private func textStyle(_ key: ScaledFont.StyleKey) -> UIFont.TextStyle {
        switch key {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        }
    }

    func testSystemPointSizesMatchUIKit() {
        for key in styleKeys {
            for step in 0..<12 {
                let traits = TextSizeScaling.traitCollection(forStep: step)
                let expected = UIFont.preferredFont(forTextStyle: textStyle(key), compatibleWith: traits).pointSize
                XCTAssertEqual(TextSizeScaling.systemPointSizes[key]?[step], expected, "\(key) step \(step)")
            }
        }
    }

    func testCustomFontMultipliersMatchUIFontMetrics() {
        for key in styleKeys {
            let metrics = UIFontMetrics(forTextStyle: textStyle(key))
            for step in 0..<12 {
                let traits = TextSizeScaling.traitCollection(forStep: step)
                let expected = metrics.scaledValue(for: 1000, compatibleWith: traits) / 1000
                XCTAssertEqual(TextSizeScaling.customFontScale(for: key, step: step), expected, accuracy: 0.001, "\(key) step \(step)")
            }
        }
    }

    /// The rounding the macOS path applies gives the sizes that
    /// `UIFontMetrics.scaledFont(for:)` gives on iOS.

    func testRoundedScalingMatchesUIFontMetrics() {
        for key in styleKeys {
            let metrics = UIFontMetrics(forTextStyle: textStyle(key))
            for base: CGFloat in [11, 13, 17, 17.2, 17.5, 22.4] {
                for step in 0..<12 where step != TextSizeScaling.largeStep {
                    let product = base * TextSizeScaling.customFontScale(for: key, step: step)
                    // Skip products too close to a rounding boundary
                    // for the precision of the table.
                    guard abs(product - product.rounded(.down) - 0.5) > 0.02 else {
                        continue
                    }

                    let traits = TextSizeScaling.traitCollection(forStep: step)
                    let expected = metrics.scaledFont(for: .systemFont(ofSize: base), compatibleWith: traits).pointSize
                    XCTAssertEqual(product.rounded(), expected, "\(key) base \(base) step \(step)")
                }
            }
        }
    }
    #endif
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class TextSizePreferenceTests: XCTestCase {
    private var suite: TestDefaults!

    private var defaults: UserDefaults {
        suite.defaults
    }

    override func setUp() {
        super.setUp()
        suite = TestDefaults()
    }

    override func tearDown() {
        suite.remove()
        suite = nil
        super.tearDown()
    }

    @MainActor
    func testStartsAtLargeWithEverySize() {
        let preference = TextSizePreference(userDefaults: defaults)
        XCTAssertEqual(preference.dynamicTypeSize, .large)
        XCTAssertEqual(preference.range, .xSmall ... .accessibility5)
    }

    @MainActor
    func testClampsASizeIntoTheRange() {
        let preference = TextSizePreference(range: .small ... .xLarge, userDefaults: defaults)
        preference.dynamicTypeSize = .accessibility3
        XCTAssertEqual(preference.dynamicTypeSize, .xLarge)
        preference.dynamicTypeSize = .xSmall
        XCTAssertEqual(preference.dynamicTypeSize, .small)
    }

    @MainActor
    func testNarrowingTheRangeClampsTheSize() {
        let preference = TextSizePreference(userDefaults: defaults)
        preference.dynamicTypeSize = .accessibility3
        let notifications = NotificationCounter(preference)

        preference.range = .xSmall ... .xxxLarge

        XCTAssertEqual(preference.dynamicTypeSize, .xxxLarge)
        XCTAssertEqual(notifications.count, 1)
    }

    @MainActor
    func testAssigningTheSameSizeDoesNothing() {
        let preference = TextSizePreference(userDefaults: defaults)
        var changes = 0
        let cancellable = preference.objectWillChange.sink { changes += 1 }
        let notifications = NotificationCounter(preference)

        preference.dynamicTypeSize = .large
        XCTAssertEqual(changes, 0)
        XCTAssertEqual(notifications.count, 0)

        preference.dynamicTypeSize = .xLarge
        preference.dynamicTypeSize = .xLarge
        XCTAssertEqual(changes, 1)
        XCTAssertEqual(notifications.count, 1)
        cancellable.cancel()
    }

    @MainActor
    func testIncreaseAndDecreaseStayInTheRange() {
        let preference = TextSizePreference(range: .large ... .xLarge, userDefaults: defaults)
        XCTAssertTrue(preference.canIncrease)
        XCTAssertFalse(preference.canDecrease)

        preference.increase()
        XCTAssertEqual(preference.dynamicTypeSize, .xLarge)
        XCTAssertFalse(preference.canIncrease)
        preference.increase()
        XCTAssertEqual(preference.dynamicTypeSize, .xLarge)

        preference.decrease()
        preference.decrease()
        XCTAssertEqual(preference.dynamicTypeSize, .large)
    }

    @MainActor
    func testResetReturnsToLargeWithinTheRange() {
        let preference = TextSizePreference(userDefaults: defaults)
        preference.dynamicTypeSize = .accessibility2
        preference.reset()
        XCTAssertEqual(preference.dynamicTypeSize, .large)

        let larger = TextSizePreference(range: .xLarge ... .accessibility5, userDefaults: defaults, key: "Larger")
        larger.dynamicTypeSize = .accessibility2
        larger.reset()
        XCTAssertEqual(larger.dynamicTypeSize, .xLarge)
    }

    @MainActor
    func testStoresTheSize() {
        let preference = TextSizePreference(userDefaults: defaults)
        preference.dynamicTypeSize = .accessibility1

        XCTAssertEqual(defaults.string(forKey: "ScaledFontTextSize"), "accessibility1")
        XCTAssertEqual(TextSizePreference(userDefaults: defaults).dynamicTypeSize, .accessibility1)
    }

    @MainActor
    func testUnknownStoredSizeStartsAtLarge() {
        defaults.set("gigantic", forKey: "ScaledFontTextSize")
        XCTAssertEqual(TextSizePreference(userDefaults: defaults).dynamicTypeSize, .large)
        XCTAssertEqual(TextSizePreference(range: .xLarge ... .xxLarge, userDefaults: defaults).dynamicTypeSize, .xLarge)
    }

    @MainActor
    func testPostsTheNotificationOnTheMainThread() {
        let preference = TextSizePreference(userDefaults: defaults)
        let notified = expectation(forNotification: TextSizePreference.didChangeNotification, object: preference) { _ in
            XCTAssertTrue(Thread.isMainThread)
            return true
        }

        preference.increase()

        wait(for: [notified], timeout: 1)
    }
}

/// A user defaults suite for one test.
///
/// Removing a persistent domain leaves an empty property list
/// behind on macOS, so ``remove()`` deletes that file as well.

private final class TestDefaults {
    let suiteName = "ScaledFontTests.\(UUID().uuidString)"
    let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    func remove() {
        defaults.removePersistentDomain(forName: suiteName)
        #if os(macOS)
        let file = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/\(suiteName).plist")
        try? FileManager.default.removeItem(at: file)
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private final class NotificationCounter {
    private(set) var count = 0
    private var observer: NSObjectProtocol?

    init(_ preference: TextSizePreference) {
        observer = NotificationCenter.default.addObserver(
            forName: TextSizePreference.didChangeNotification,
            object: preference,
            queue: nil
        ) { [weak self] _ in
            self?.count += 1
        }
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

#if canImport(UIKit) && !os(watchOS)
@available(iOS 15.0, tvOS 15.0, *)
final class UIKitTextSizeTests: XCTestCase {
    private let futura = ScaledFont(fontName: "Futura", bundle: .module)
    private let missingHeadline = ScaledFont(fontName: "MissingHeadline", bundle: .module)
    private let sizes: [(DynamicTypeSize, UIContentSizeCategory)] = [
        (.xSmall, .extraSmall),
        (.large, .large),
        (.accessibility5, .accessibilityExtraExtraExtraLarge)
    ]

    func testSystemFontIsThePreferredFontForTheExplicitSize() {
        for (size, category) in sizes {
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            let expected = UIFont.preferredFont(forTextStyle: .headline, compatibleWith: traits)
            let font = missingHeadline.font(forTextStyle: .headline, dynamicTypeSize: size)
            XCTAssertEqual(font.pointSize, expected.pointSize, "\(size)")
            XCTAssertEqual(font.fontName, expected.fontName, "\(size)")
        }
    }

    func testCustomFontIsScaledFromTheStyleDictionaryForTheExplicitSize() throws {
        let base = try XCTUnwrap(UIFont(name: "Futura-Medium", size: 17))
        for (size, category) in sizes {
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            let expected = UIFontMetrics(forTextStyle: .body).scaledFont(for: base, compatibleWith: traits)
            let font = futura.font(forTextStyle: .body, dynamicTypeSize: size)
            XCTAssertEqual(font.fontName, "Futura-Medium", "\(size)")
            XCTAssertEqual(font.pointSize, expected.pointSize, "\(size)")
        }
    }
}
#endif

#if os(macOS)
@available(macOS 12.0, *)
final class MacTextSizeTests: XCTestCase {
    private let futura = ScaledFont(fontName: "Futura", bundle: .module)
    private let missingHeadline = ScaledFont(fontName: "MissingHeadline", bundle: .module)

    func testLargeKeepsTheCustomFont() {
        for style: NSFont.TextStyle in [.body, .headline, .caption1] {
            let plain = futura.font(forTextStyle: style)
            let large = futura.font(forTextStyle: style, dynamicTypeSize: .large)
            XCTAssertEqual(large.fontName, plain.fontName)
            XCTAssertEqual(large.pointSize, plain.pointSize)
        }
    }

    func testLargeKeepsAFractionalSize() {
        let scaledFont = ScaledFont(fontName: "FractionalSize", bundle: .module)
        XCTAssertEqual(scaledFont.font(forTextStyle: .body).pointSize, 17.2)
        XCTAssertEqual(scaledFont.font(forTextStyle: .body, dynamicTypeSize: .large).pointSize, 17.2)
    }

    func testLargeKeepsTheSystemFont() {
        let plain = missingHeadline.font(forTextStyle: .headline)
        let large = missingHeadline.font(forTextStyle: .headline, dynamicTypeSize: .large)
        XCTAssertEqual(large.fontName, plain.fontName)
        XCTAssertEqual(large.pointSize, plain.pointSize)
    }

    /// A 17 pt body font gets the sizes `UIFontMetrics` gives it
    /// on iOS: 19 pt at xLarge and 48 pt at accessibility5.

    func testCustomFontScalesLikeUIFontMetrics() {
        let body = futura.font(forTextStyle: .body, dynamicTypeSize: .xLarge)
        XCTAssertEqual(body.fontName, "Futura-Medium")
        XCTAssertEqual(body.pointSize, 19)
        XCTAssertEqual(futura.font(forTextStyle: .body, dynamicTypeSize: .accessibility5).pointSize, 48)
    }

    func testScaledSizesAreWholePoints() {
        let fractional = ScaledFont(fontName: "FractionalSize", bundle: .module)
        XCTAssertEqual(fractional.font(forTextStyle: .body, dynamicTypeSize: .xLarge).pointSize, 19)
        XCTAssertEqual(missingHeadline.font(forTextStyle: .headline, dynamicTypeSize: .xLarge).pointSize, 15)
    }

    /// Fractional sizes keep their fraction at Large, and a larger
    /// size still never gets a smaller font. Rounding alone gives
    /// 16 points at medium for the 15.9 point large title, and 8
    /// points at xLarge for the 8.02 point title.

    func testFractionalSizesNeverShrinkAsTheSizeGrows() {
        let fractional = ScaledFont(fontName: "FractionalSize", bundle: .module)
        for style: NSFont.TextStyle in [.largeTitle, .title1, .body, .footnote, .caption2] {
            let fonts = DynamicTypeSize.allCases.map { fractional.font(forTextStyle: style, dynamicTypeSize: $0) }
            XCTAssertEqual(Set(fonts.map(\.fontName)), ["Futura-Medium"], "\(style)")

            let sizes = fonts.map(\.pointSize)
            for (smaller, larger) in zip(sizes, sizes.dropFirst()) {
                XCTAssertGreaterThanOrEqual(larger, smaller, "\(style): \(sizes)")
            }
            XCTAssertEqual(sizes[3], fractional.font(forTextStyle: style).pointSize, "\(style)")
        }
    }

    /// Rounding gives 18 points up to medium for a 17.8 point
    /// caption2 font, more than its size at Large, so those sizes
    /// keep 17.8 points.

    func testFractionalCaption2DoesNotShrinkAtLarge() {
        let fractional = ScaledFont(fontName: "FractionalSize", bundle: .module)
        let medium = fractional.font(forTextStyle: .caption2, dynamicTypeSize: .medium)
        let large = fractional.font(forTextStyle: .caption2, dynamicTypeSize: .large)
        XCTAssertEqual(medium.fontName, "Futura-Medium")
        XCTAssertEqual(large.fontName, "Futura-Medium")
        XCTAssertGreaterThanOrEqual(large.pointSize, medium.pointSize)

        XCTAssertEqual(fractional.font(forTextStyle: .caption2, dynamicTypeSize: .xSmall).pointSize, 17.8)
        XCTAssertEqual(medium.pointSize, 17.8)
        XCTAssertEqual(large.pointSize, 17.8)
        XCTAssertEqual(fractional.font(forTextStyle: .caption2, dynamicTypeSize: .xLarge).pointSize, 25)

        let bold = fractional.font(forTextStyle: .caption2, weight: .bold, dynamicTypeSize: .medium)
        XCTAssertEqual(bold.fontName, "Futura-Bold")
        XCTAssertEqual(bold.pointSize, 17.8)
    }

    func testSystemFontScalesLikeThePreferredFontSizes() {
        let base = NSFont.preferredFont(forTextStyle: .headline)
        let headline = missingHeadline.font(forTextStyle: .headline, dynamicTypeSize: .accessibility5)
        XCTAssertEqual(headline.pointSize, (base.pointSize * 53 / 17).rounded())
        XCTAssertEqual(headline.fontName, base.fontName)
        XCTAssertTrue(headline.fontDescriptor.symbolicTraits.contains(.bold))
    }

    func testVariantsApplyAtTheScaledSize() {
        let bold = futura.font(forTextStyle: .body, weight: .bold, dynamicTypeSize: .xLarge)
        XCTAssertEqual(bold.fontName, "Futura-Bold")
        XCTAssertEqual(bold.pointSize, 19)

        let italic = futura.font(forTextStyle: .subheadline, weight: .bold, dynamicTypeSize: .xLarge)
        XCTAssertEqual(italic.fontName, "Futura-MediumItalic")

        let variants = ScaledFont(fontName: "SystemVariants", bundle: .module)
        let serif = variants.font(forTextStyle: .body, dynamicTypeSize: .accessibility3)
        XCTAssertEqual(serif.familyName, variants.font(forTextStyle: .body).familyName)
        XCTAssertEqual(serif.pointSize, (NSFont.preferredFont(forTextStyle: .body).pointSize * 40 / 17).rounded())
    }

    func testFontsGrowWithTheSize() {
        var custom: CGFloat = 0
        var system: CGFloat = 0
        for size in DynamicTypeSize.allCases {
            let nextCustom = futura.font(forTextStyle: .body, dynamicTypeSize: size).pointSize
            let nextSystem = missingHeadline.font(forTextStyle: .headline, dynamicTypeSize: size).pointSize
            XCTAssertGreaterThanOrEqual(nextCustom, custom, "\(size)")
            XCTAssertGreaterThanOrEqual(nextSystem, system, "\(size)")
            custom = nextCustom
            system = nextSystem
        }
        XCTAssertGreaterThan(custom, futura.font(forTextStyle: .body).pointSize * 2.5)
        XCTAssertGreaterThan(system, missingHeadline.font(forTextStyle: .headline).pointSize * 2.5)
    }
}

@available(macOS 12.0, *)
final class MacTextSizeSwiftUITests: XCTestCase {
    private let futura = ScaledFont(fontName: "Futura", bundle: .module)
    private let sample = "The quick brown fox jumps"

    @MainActor
    private func measure<V: View>(_ view: V) -> CGSize {
        NSHostingView(rootView: view.fixedSize()).fittingSize
    }

    @MainActor
    private func text(_ scaledFont: ScaledFont) -> some View {
        Text(sample).scaledFont(.body).scaledFont(scaledFont)
    }

    @MainActor
    func testLargeMatchesTodaysFont() {
        let today = measure(Text(sample).font(.custom("Futura-Medium", size: 17, relativeTo: .body)))
        XCTAssertEqual(measure(text(futura)), today)
        XCTAssertEqual(measure(text(futura).dynamicTypeSize(.large)), today)
    }

    @MainActor
    func testTextGrowsWithTheSize() {
        let missing = ScaledFont(fontName: "Missing", bundle: .module)
        for scaledFont in [futura, missing] {
            let large = measure(text(scaledFont).dynamicTypeSize(.large))
            let larger = measure(text(scaledFont).dynamicTypeSize(.accessibility3))
            XCTAssertGreaterThan(larger.height, large.height * 1.8)
        }
    }

    @MainActor
    func testRangeClampsTheSize() {
        let clamped = measure(text(futura).dynamicTypeSize(...DynamicTypeSize.xxxLarge).dynamicTypeSize(.accessibility5))
        XCTAssertEqual(clamped, measure(text(futura).dynamicTypeSize(.xxxLarge)))
    }

    @MainActor
    func testTheSameHostingViewUpdatesWhenThePreferenceChanges() {
        let suite = TestDefaults()
        defer { suite.remove() }

        let preference = TextSizePreference(userDefaults: suite.defaults)
        let host = NSHostingView(rootView: PreferenceText(preference: preference, scaledFont: futura, sample: sample))
        let before = host.fittingSize

        preference.dynamicTypeSize = .accessibility3
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        host.layoutSubtreeIfNeeded()

        XCTAssertGreaterThan(host.fittingSize.height, before.height * 1.8)
    }
}

@available(macOS 12.0, *)
private struct PreferenceText: View {
    @ObservedObject var preference: TextSizePreference
    let scaledFont: ScaledFont
    let sample: String

    var body: some View {
        Text(sample)
            .scaledFont(.body)
            .scaledFont(scaledFont)
            .dynamicTypeSize(preference.dynamicTypeSize)
            .fixedSize()
    }
}
#endif
