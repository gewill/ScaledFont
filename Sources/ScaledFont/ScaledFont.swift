//  Copyright (c) 2017-2021 Keith Harrison. All rights reserved.
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

#if canImport(UIKit)
import UIKit
typealias PlatformFont = UIFont
typealias PlatformFontDescriptor = UIFontDescriptor
#elseif canImport(AppKit)
import AppKit
typealias PlatformFont = NSFont
typealias PlatformFontDescriptor = NSFontDescriptor
#endif
import SwiftUI

/// A utility type to help you use custom fonts with
/// dynamic type.
///
/// To use this type you must supply the name of a style
/// dictionary for the font when creating the `ScaledFont`.
/// The style dictionary should be stored as a property list
/// file in the main bundle.
///
/// The style dictionary contains an entry for each text
/// style. The available text styles are:
///
/// - `largeTitle`, `title`, `title2`, `title3`
/// -  `headline`, `subheadline`, `body`, `callout`
/// -  `footnote`, `caption`, `caption2`
///
/// For a custom font, the value of each entry is a dictionary
/// with two keys:
///
/// + `fontName`: A `String` which is the font name.
/// + `fontSize`: A number which is the point size to use
///             at the `.large` (base) content size.
///
/// For example to use a 17 pt Noteworthy-Bold font
/// for the `.headline` style at the `.large` content size:
///
///     <dict>
///         <key>headline</key>
///         <dict>
///             <key>fontName</key>
///             <string>Noteworthy-Bold</string>
///             <key>fontSize</key>
///             <integer>17</integer>
///         </dict>
///     </dict>
///
/// For a system font, omit `fontName` and `fontSize` and use
/// the optional variant keys:
///
/// + `design`: `default`, `serif` or `monospaced`
/// + `weight`: `regular` or `bold`
///
/// You can override the style dictionary at the call site:
///
///     Text("Metadata")
///     .scaledFont(.subheadline, design: .serif, weight: .bold)
///
/// You do not need to include an entry for every text style
/// but if you try to use a text style that is not included
/// in the dictionary it will fallback to the system preferred
/// font.
///
/// ## Using With UIKit
///
/// For `UIKit`, apply the scaled font to text labels, text fields or text
/// views:
///
/// ```swift
/// let scaledFont = ScaledFont(fontName: "Noteworthy")
/// label.font = scaledFont.font(forTextStyle: .headline)
/// label.adjustsFontForContentSizeCategory = true
/// ```
///
/// Remember to set the `adjustsFontForContentSizeCategory` property
/// to have the font size adjust automatically when the user changes
/// their preferred content size.
///
/// ## Using With SwiftUI
///
/// For SwiftUI, add the scaled font to the environment of a view:
///
/// ```swift
/// ContentView()
/// .environment(\.scaledFont, scaledFont)
/// ```
///
/// Then apply the scaled font view modifier to any view containing
/// text in the view hierarchy:
///
/// ```swift
/// Text("Headline")
/// .scaledFont(.headline)
/// ```
///

@available(iOS 11.0, macOS 11.0, tvOS 11.0, watchOS 4.0, *)
public struct ScaledFont {
    internal enum StyleKey: String, Decodable {
        case largeTitle, title, title2, title3
        case headline, subheadline, body, callout
        case footnote, caption, caption2
    }

    internal struct FontDescription: Decodable {
        let fontSize: CGFloat?
        let fontName: String?
        let design: FontDesign?
        let weight: FontWeight?
    }

    /// The design to use for a system font.
    ///
    /// Only used for a text style that does not have a
    /// `fontName` in the style dictionary. A design that the
    /// platform does not support is ignored.
    ///
    /// New designs may be added in a later version, so include
    /// a `default` case when you switch over a design.

    public struct FontDesign: RawRepresentable, Hashable, Sendable {
        /// The name of the design in the style dictionary.
        public let rawValue: String

        /// Creates a design from its name in the style dictionary.
        ///
        /// - Parameter rawValue: The name of the design, such as
        ///   `serif`.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// The default system font design.
        public static let `default` = FontDesign(rawValue: "default")

        /// The serif system font design.
        public static let serif = FontDesign(rawValue: "serif")

        /// The monospaced system font design.
        public static let monospaced = FontDesign(rawValue: "monospaced")
    }

    /// The weight to use for the font.
    ///
    /// For a custom font, `bold` uses the matching bold face of
    /// the same font family when the family has one. A weight
    /// that the platform does not support is ignored.
    ///
    /// New weights may be added in a later version, so include
    /// a `default` case when you switch over a weight.

    public struct FontWeight: RawRepresentable, Hashable, Sendable {
        /// The name of the weight in the style dictionary.
        public let rawValue: String

        /// Creates a weight from its name in the style dictionary.
        ///
        /// - Parameter rawValue: The name of the weight, such as
        ///   `bold`.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// The regular font weight.
        public static let regular = FontWeight(rawValue: "regular")

        /// The bold font weight.
        public static let bold = FontWeight(rawValue: "bold")
    }

    internal typealias StyleDictionary = [StyleKey.RawValue: FontDescription]
    internal var styleDictionary: StyleDictionary?

    /// Create a `ScaledFont`
    ///
    /// - Parameter fontName: Name of a plist file (without the extension)
    ///   that contains the style dictionary used to scale fonts for each
    ///   text style.
    /// - Parameter bundle: The `Bundle` that contains the style dictionary.
    ///   Default is the main bundle.

    public init(fontName: String, bundle: Bundle = .main) {
        if let url = bundle.url(forResource: fontName, withExtension: "plist"),
           let data = try? Data(contentsOf: url)
        {
            let decoder = PropertyListDecoder()
            styleDictionary = try? decoder.decode(StyleDictionary.self, from: data)
        }
    }

    #if canImport(UIKit)
    /// Get the scaled font for the given text style using the
    /// style dictionary supplied at initialization.
    ///
    /// - Parameter textStyle: The `UIFont.TextStyle` for the
    ///   font.
    /// - Returns: A `UIFont` of the custom font that has been
    ///   scaled for the users currently selected preferred
    ///   text size.
    ///
    /// - Note: If the style dictionary does not have
    ///   a font for this text style the default preferred
    ///   font is returned.

    public func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        font(forPlatformTextStyle: textStyle, design: nil, weight: nil)
    }

    /// Get the scaled font for the given text style overriding
    /// the variants of the style dictionary.
    ///
    /// - Parameter textStyle: The `UIFont.TextStyle` for the
    ///   font.
    /// - Parameter design: The design to use for a system font.
    ///   Pass `nil` to use the design of the style dictionary.
    /// - Parameter weight: The weight to use for the font. Pass
    ///   `nil` to use the weight of the style dictionary.
    /// - Returns: A `UIFont` of the custom font that has been
    ///   scaled for the users currently selected preferred
    ///   text size.
    ///
    /// - Note: The `design` is only used for a text style that
    ///   does not have a `fontName` in the style dictionary.

    public func font(
        forTextStyle textStyle: UIFont.TextStyle,
        design: FontDesign? = nil,
        weight: FontWeight? = nil
    ) -> UIFont {
        font(forPlatformTextStyle: textStyle, design: design, weight: weight)
    }

    #if !os(watchOS)
    /// Get the scaled font for the given text style at an explicit
    /// Dynamic Type size instead of the size chosen in the system
    /// settings.
    ///
    /// - Parameter textStyle: The `UIFont.TextStyle` for the
    ///   font.
    /// - Parameter design: The design to use for a system font.
    ///   Pass `nil` to use the design of the style dictionary.
    /// - Parameter weight: The weight to use for the font. Pass
    ///   `nil` to use the weight of the style dictionary.
    /// - Parameter dynamicTypeSize: The Dynamic Type size to scale
    ///   the font for.
    /// - Returns: A `UIFont` scaled for the given Dynamic Type
    ///   size, whatever size is chosen in the system settings.
    ///
    /// - Note: A custom font is scaled with `UIFontMetrics` from
    ///   the size in the style dictionary, and a system font is
    ///   the preferred font for the size. A size this version
    ///   does not know uses the size chosen in the system settings.

    @available(iOS 15.0, tvOS 15.0, *)
    public func font(
        forTextStyle textStyle: UIFont.TextStyle,
        design: FontDesign? = nil,
        weight: FontWeight? = nil,
        dynamicTypeSize: DynamicTypeSize
    ) -> UIFont {
        font(forPlatformTextStyle: textStyle, design: design, weight: weight, step: dynamicTypeSize.scalingStep)
    }
    #endif
    #elseif canImport(AppKit)
    /// Get the scaled font for the given text style using the
    /// style dictionary supplied at initialization.
    ///
    /// - Parameter textStyle: The `NSFont.TextStyle` for the
    ///   font.
    /// - Returns: An `NSFont` of the custom font for this text
    ///   style.
    ///
    /// - Note: If the style dictionary does not have
    ///   a font for this text style the default preferred
    ///   font is returned.

    public func font(forTextStyle textStyle: NSFont.TextStyle) -> NSFont {
        font(forPlatformTextStyle: textStyle, design: nil, weight: nil)
    }

    /// Get the scaled font for the given text style overriding
    /// the variants of the style dictionary.
    ///
    /// - Parameter textStyle: The `NSFont.TextStyle` for the
    ///   font.
    /// - Parameter design: The design to use for a system font.
    ///   Pass `nil` to use the design of the style dictionary.
    /// - Parameter weight: The weight to use for the font. Pass
    ///   `nil` to use the weight of the style dictionary.
    /// - Returns: An `NSFont` of the custom font for this text
    ///   style.
    ///
    /// - Note: The `design` is only used for a text style that
    ///   does not have a `fontName` in the style dictionary.

    public func font(
        forTextStyle textStyle: NSFont.TextStyle,
        design: FontDesign? = nil,
        weight: FontWeight? = nil
    ) -> NSFont {
        font(forPlatformTextStyle: textStyle, design: design, weight: weight)
    }

    /// Get the scaled font for the given text style at a Dynamic
    /// Type size that the app chooses.
    ///
    /// macOS has no Dynamic Type, so the font is scaled here: a
    /// custom font by the factor `UIFontMetrics` applies to it on
    /// iOS, and a system font by the ratio of the iOS preferred
    /// font sizes. Sizes are rounded to whole points, as they are
    /// on iOS, except at `.large`, where the font is exactly the
    /// one you get without a size. A rounded size never passes the
    /// size at `.large`, so a larger Dynamic Type size never gets a
    /// smaller font, even for a fractional style dictionary size
    /// such as 17.8 points.
    ///
    /// - Parameter textStyle: The `NSFont.TextStyle` for the
    ///   font.
    /// - Parameter design: The design to use for a system font.
    ///   Pass `nil` to use the design of the style dictionary.
    /// - Parameter weight: The weight to use for the font. Pass
    ///   `nil` to use the weight of the style dictionary.
    /// - Parameter dynamicTypeSize: The Dynamic Type size to scale
    ///   the font for.
    /// - Returns: An `NSFont` scaled for the given Dynamic Type
    ///   size.

    @available(macOS 12.0, *)
    public func font(
        forTextStyle textStyle: NSFont.TextStyle,
        design: FontDesign? = nil,
        weight: FontWeight? = nil,
        dynamicTypeSize: DynamicTypeSize
    ) -> NSFont {
        font(forPlatformTextStyle: textStyle, design: design, weight: weight, step: dynamicTypeSize.scalingStep)
    }
    #endif

    /// - Parameter step: The index of an explicit Dynamic Type size
    ///   in the scaling tables, or `nil` for the size chosen in the
    ///   system settings.

    private func font(
        forPlatformTextStyle textStyle: PlatformFont.TextStyle,
        design: FontDesign?,
        weight: FontWeight?,
        step: Int? = nil
    ) -> PlatformFont {
        let styleKey = StyleKey(textStyle)
        let fontDescription = styleKey.flatMap { styleDictionary?[$0.rawValue] }
        let effectiveDesign = design ?? fontDescription?.design
        let effectiveWeight = weight ?? fontDescription?.weight

        if let fontName = fontDescription?.fontName,
           let fontSize = fontDescription?.fontSize,
           var font = PlatformFont(name: fontName, size: fontSize) {
            if effectiveWeight == .bold {
                font = boldFontIfAvailable(for: font)
            }

            #if canImport(UIKit)
            let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
            #if !os(watchOS)
            if let step = step {
                return fontMetrics.scaledFont(for: font, compatibleWith: TextSizeScaling.traitCollection(forStep: step))
            }
            #endif
            return fontMetrics.scaledFont(for: font)
            #elseif canImport(AppKit)
            // macOS has no Dynamic Type, so scale the font by the
            // factor `UIFontMetrics` applies to it on iOS and round
            // to whole points, as `UIFontMetrics` does, without
            // passing the size at Large.
            guard let step = step, step != TextSizeScaling.largeStep, let styleKey = styleKey else {
                return font
            }

            let scale = TextSizeScaling.customFontScale(for: styleKey, step: step)
            let size = TextSizeScaling.scaledSize(font.pointSize, by: scale, step: step)
            return PlatformFont(descriptor: font.fontDescriptor.withSize(size), size: size) ?? font
            #endif
        }

        return systemFont(forTextStyle: textStyle, design: effectiveDesign, weight: effectiveWeight, step: step)
    }

    private func systemFont(
        forTextStyle textStyle: PlatformFont.TextStyle,
        design: FontDesign?,
        weight: FontWeight?,
        step: Int?
    ) -> PlatformFont {
        #if canImport(UIKit)
        // The preferred font descriptor is already scaled for the
        // users selected text size, or for the explicit size, so
        // the font built from it must not be scaled again with
        // `UIFontMetrics`.
        var descriptor = PlatformFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        #if !os(watchOS)
        if let step = step {
            descriptor = PlatformFontDescriptor.preferredFontDescriptor(
                withTextStyle: textStyle,
                compatibleWith: TextSizeScaling.traitCollection(forStep: step)
            )
        }
        #endif

        if let weight = weight, let systemWeight = weight.systemWeight {
            descriptor = descriptor.addingAttributes([
                .traits: [PlatformFontDescriptor.TraitKey.weight: systemWeight.rawValue]
            ])
        }

        if #available(iOS 13.0, tvOS 13.0, watchOS 7.0, *),
           let design = design,
           let systemDesign = design.systemDesign,
           let designedDescriptor = descriptor.withDesign(systemDesign) {
            descriptor = designedDescriptor
        }

        return PlatformFont(descriptor: descriptor, size: 0)
        #elseif canImport(AppKit)
        let preferredFont = PlatformFont.preferredFont(forTextStyle: textStyle)
        var font = preferredFont
        var size = preferredFont.pointSize

        // macOS has no Dynamic Type, so scale the size of the text
        // style by the ratio of the iOS preferred font sizes and
        // round to whole points, as the preferred fonts are.
        if let step = step, step != TextSizeScaling.largeStep, let styleKey = StyleKey(textStyle) {
            let scale = TextSizeScaling.systemFontScale(for: styleKey, step: step)
            size = TextSizeScaling.scaledSize(size, by: scale, step: step)
            let descriptor = PlatformFontDescriptor.preferredFontDescriptor(forTextStyle: textStyle, options: [:])
            font = PlatformFont(descriptor: descriptor.withSize(size), size: size) ?? preferredFont
        }

        if let weight = weight, let systemWeight = weight.systemWeight {
            font = PlatformFont.systemFont(ofSize: size, weight: systemWeight)
        }

        if let design = design,
           let systemDesign = design.systemDesign,
           let descriptor = font.fontDescriptor.withDesign(systemDesign),
           let designedFont = NSFont(descriptor: descriptor, size: font.pointSize) {
            font = designedFont
        }

        return font
        #endif
    }

    private func boldFontIfAvailable(for font: PlatformFont) -> PlatformFont {
        #if canImport(UIKit)
        let traits = font.fontDescriptor.symbolicTraits
        guard !traits.contains(.traitBold),
              let descriptor = font.fontDescriptor.withSymbolicTraits(traits.union(.traitBold))
        else {
            return font
        }

        let boldFont = PlatformFont(descriptor: descriptor, size: font.pointSize)
        #elseif canImport(AppKit)
        guard !font.fontDescriptor.symbolicTraits.contains(.bold) else {
            return font
        }

        let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
        #endif

        return isBoldVariant(boldFont, of: font) ? boldFont : font
    }

    /// Check that the candidate is the bold face of the font from
    /// the same font family with the other style traits unchanged.

    private func isBoldVariant(_ candidate: PlatformFont, of font: PlatformFont) -> Bool {
        guard candidate.fontName != font.fontName,
              candidate.familyName == font.familyName
        else {
            return false
        }

        let candidateTraits = candidate.fontDescriptor.symbolicTraits
        let fontTraits = font.fontDescriptor.symbolicTraits

        #if canImport(UIKit)
        return candidateTraits.contains(.traitBold)
            && candidateTraits.contains(.traitItalic) == fontTraits.contains(.traitItalic)
            && candidateTraits.contains(.traitCondensed) == fontTraits.contains(.traitCondensed)
            && candidateTraits.contains(.traitExpanded) == fontTraits.contains(.traitExpanded)
        #elseif canImport(AppKit)
        return candidateTraits.contains(.bold)
            && candidateTraits.contains(.italic) == fontTraits.contains(.italic)
            && candidateTraits.contains(.condensed) == fontTraits.contains(.condensed)
            && candidateTraits.contains(.expanded) == fontTraits.contains(.expanded)
        #endif
    }

    /// The name of the bold face of the given font name.
    ///
    /// - Returns: The given font name when the font family does
    ///   not have a matching bold face.

    internal func boldFontName(for fontName: String, size: CGFloat) -> String {
        guard let font = PlatformFont(name: fontName, size: size) else {
            return fontName
        }

        return boldFontIfAvailable(for: font).fontName
    }
}

extension ScaledFont.FontDescription {
    private enum CodingKeys: String, CodingKey {
        case fontSize, fontName, design, weight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fontSize = try container.decodeIfPresent(CGFloat.self, forKey: .fontSize)
        fontName = try container.decodeIfPresent(String.self, forKey: .fontName)
        design = try container.decodeIfPresent(String.self, forKey: .design)
            .map(ScaledFont.FontDesign.init(rawValue:))
        weight = try container.decodeIfPresent(String.self, forKey: .weight)
            .map(ScaledFont.FontWeight.init(rawValue:))

        // A custom font needs both keys. Reject the style dictionary
        // when only one of them is present instead of silently using
        // the system font for this text style.
        guard (fontName == nil) == (fontSize == nil) else {
            throw DecodingError.dataCorruptedError(
                forKey: fontName == nil ? .fontName : .fontSize,
                in: container,
                debugDescription: "A custom font needs both a fontName and a fontSize."
            )
        }
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 7.0, *)
extension ScaledFont.FontDesign {
    /// The matching system design or `nil` for a design that is
    /// not supported.

    var systemDesign: PlatformFontDescriptor.SystemDesign? {
        switch self {
            case .default: return .default
            case .serif: return .serif
            case .monospaced: return .monospaced
            default: return nil
        }
    }
}

extension ScaledFont.FontWeight {
    /// The matching system weight or `nil` for a weight that is
    /// not supported.

    var systemWeight: PlatformFont.Weight? {
        switch self {
            case .regular: return .regular
            case .bold: return .bold
            default: return nil
        }
    }
}

@available(iOS 11.0, macOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension ScaledFont.StyleKey {
    init?(_ textStyle: PlatformFont.TextStyle) {
        #if !os(tvOS)
        if #available(watchOS 5.0, *), textStyle == .largeTitle {
            self = .largeTitle
            return
        }
        #endif
        switch textStyle {
            case .title1: self = .title
            case .title2: self = .title2
            case .title3: self = .title3
            case .headline: self = .headline
            case .subheadline: self = .subheadline
            case .body: self = .body
            case .callout: self = .callout
            case .footnote: self = .footnote
            case .caption1: self = .caption
            case .caption2: self = .caption2
            default: return nil
        }
    }
}
