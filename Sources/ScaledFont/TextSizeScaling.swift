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

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// The scale factors for an explicit Dynamic Type size on a
/// platform that does not scale fonts itself.
///
/// Each table has one entry per Dynamic Type size, from `xSmall`
/// to `accessibility5`, for every text style. The values were
/// measured with public UIKit API on iOS 27, and the tests that
/// run on iOS compare them with the live values.

enum TextSizeScaling {
    /// The index of the default Large size in the tables.
    static let largeStep = 3

    /// The point sizes of the preferred system fonts on iOS, as
    /// published in the Human Interface Guidelines.
    static let systemPointSizes: [ScaledFont.StyleKey: [CGFloat]] = [
        .largeTitle: [31, 32, 33, 34, 36, 38, 40, 44, 48, 52, 56, 60],
        .title: [25, 26, 27, 28, 30, 32, 34, 38, 43, 48, 53, 58],
        .title2: [19, 20, 21, 22, 24, 26, 28, 34, 39, 44, 50, 56],
        .title3: [17, 18, 19, 20, 22, 24, 26, 31, 37, 43, 49, 55],
        .headline: [14, 15, 16, 17, 19, 21, 23, 28, 33, 40, 47, 53],
        .subheadline: [12, 13, 14, 15, 17, 19, 21, 25, 30, 36, 42, 49],
        .body: [14, 15, 16, 17, 19, 21, 23, 28, 33, 40, 47, 53],
        .callout: [13, 14, 15, 16, 18, 20, 22, 26, 32, 38, 44, 51],
        .footnote: [12, 12, 12, 13, 15, 17, 19, 23, 27, 33, 38, 44],
        .caption: [11, 11, 11, 12, 14, 16, 18, 22, 26, 32, 37, 43],
        .caption2: [11, 11, 11, 11, 13, 15, 17, 20, 24, 29, 34, 40]
    ]

    /// The factors `UIFontMetrics` applies to a custom font on iOS.
    /// They do not depend on the size of the font.
    static let customFontMultipliers: [ScaledFont.StyleKey: [CGFloat]] = [
        .largeTitle: [0.9267, 0.9513, 0.9757, 1, 1.0487, 1.1220, 1.1707, 1.2683, 1.3903, 1.4877, 1.6097, 1.7073],
        .title: [0.9117, 0.9413, 0.9707, 1, 1.0587, 1.1177, 1.2060, 1.3530, 1.5000, 1.6763, 1.7940, 2.0000],
        .title2: [0.8570, 0.8930, 0.9287, 1, 1.0713, 1.1430, 1.2143, 1.4643, 1.6787, 1.8570, 2.1070, 2.3570],
        .title3: [0.8800, 0.9200, 0.9600, 1, 1.1200, 1.2000, 1.2800, 1.5200, 1.7600, 2.0400, 2.3200, 2.6000],
        .headline: [0.8637, 0.9090, 0.9547, 1, 1.0910, 1.1817, 1.3183, 1.5453, 1.8183, 2.1817, 2.3183, 2.8183],
        .subheadline: [0.8000, 0.9000, 0.9500, 1, 1.1000, 1.2000, 1.3000, 1.5500, 1.8000, 2.1500, 2.5000, 2.9000],
        .body: [0.8637, 0.9090, 0.9547, 1, 1.0910, 1.1817, 1.3183, 1.5453, 1.8183, 2.1817, 2.5453, 2.8183],
        .callout: [0.8570, 0.9047, 0.9523, 1, 1.0953, 1.1903, 1.3333, 1.5237, 1.8570, 2.1903, 2.4763, 2.8570],
        .footnote: [0.8890, 0.8890, 0.8890, 1, 1.1110, 1.2223, 1.3333, 1.6110, 1.8333, 2.2223, 2.5557, 2.8890],
        .caption: [0.8127, 0.8127, 0.8127, 1, 1.1877, 1.3127, 1.4377, 1.6877, 2.0000, 2.4377, 2.7500, 3.1877],
        .caption2: [1, 1, 1, 1, 1.3847, 1.5383, 1.6923, 1.9230, 2.2307, 2.6923, 3.1540, 3.6923]
    ]

    /// The factor for a system font of the text style at the step:
    /// the ratio of the iOS preferred font size at the step to the
    /// size at Large.

    static func systemFontScale(for style: ScaledFont.StyleKey, step: Int) -> CGFloat {
        guard let sizes = systemPointSizes[style], sizes.indices.contains(step) else {
            return 1
        }

        return sizes[step] / sizes[largeStep]
    }

    /// The factor for a custom font of the text style at the step.

    static func customFontScale(for style: ScaledFont.StyleKey, step: Int) -> CGFloat {
        guard let multipliers = customFontMultipliers[style], multipliers.indices.contains(step) else {
            return 1
        }

        return multipliers[step]
    }

    /// The size of a font at the step: its size at Large scaled by
    /// the factor and rounded to whole points, as on iOS.
    ///
    /// At Large a font keeps its size, which can have a fraction,
    /// such as a style dictionary size of 17.8 points. The rounded
    /// size of a nearby step could pass it, and a larger text size
    /// would then get a smaller font, so the size of a smaller step
    /// is at most the size at Large, and the size of a larger step
    /// at least that size.

    static func scaledSize(_ size: CGFloat, by scale: CGFloat, step: Int) -> CGFloat {
        let rounded = (size * scale).rounded()
        if step < largeStep {
            return min(rounded, size)
        }
        if step > largeStep {
            return max(rounded, size)
        }
        return size
    }

    #if canImport(UIKit) && !os(watchOS)
    /// A trait collection with the content size category of the
    /// step.

    static func traitCollection(forStep step: Int) -> UITraitCollection {
        let categories: [UIContentSizeCategory] = [
            .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge,
            .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
            .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge
        ]
        let category = categories.indices.contains(step) ? categories[step] : .large
        return UITraitCollection(preferredContentSizeCategory: category)
    }
    #endif
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension DynamicTypeSize {
    /// The index of the size in the scaling tables, or `nil` for a
    /// size this version does not know.

    var scalingStep: Int? {
        switch self {
        case .xSmall: return 0
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        case .xLarge: return 4
        case .xxLarge: return 5
        case .xxxLarge: return 6
        case .accessibility1: return 7
        case .accessibility2: return 8
        case .accessibility3: return 9
        case .accessibility4: return 10
        case .accessibility5: return 11
        @unknown default: return nil
        }
    }
}
