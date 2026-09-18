# Changelog

All notable changes to this fork of [ScaledFont](https://github.com/kharrison/ScaledFont) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This fork continues from upstream 1.0.5. It does not include the changes in upstream 1.0.6 and 1.0.7: compatibility with strict Swift concurrency checking, the removal of the `LibraryContentProvider`, and changes to the Swift tools version.

## [Unreleased]

### Added

- An in-app text size for macOS, where there is no Dynamic Type. See [#6](https://github.com/gewill/ScaledFont/issues/6).
  - `font(forTextStyle:design:weight:dynamicTypeSize:)` returns a font scaled for a Dynamic Type size that the app chooses. A custom font scales by the factor `UIFontMetrics` applies on iOS and a system font by the ratio of the iOS preferred font sizes, both rounded to whole points as on iOS, and `.large` returns the same font as before.
  - On macOS 12 and later, the `scaledFont(_:)` modifiers scale their fonts for the `dynamicTypeSize` of the environment.
  - `TextSizePreference` stores the size in the user defaults of the app, keeps it within a range that includes every accessibility size by default, and posts a notification when it changes.
- `font(forTextStyle:design:weight:dynamicTypeSize:)` on iOS, iPadOS, tvOS and visionOS, where the explicit size replaces the size chosen in the system settings for that font.
- `TextSizeDemo` in the `Examples` folder, a macOS app that shows the in-app text size with SwiftUI and AppKit. Run it with `swift run TextSizeDemo` in that folder.
- `Examples/SystemFonts.plist`, a style dictionary that uses the system font with the serif and monospaced designs and a bold weight.
- README sections on using ScaledFont with AppKit and on the in-app text size.
- README sections on what this fork adds, on macOS support and on installing the fork, and a link to the documentation on the Swift Package Index.

### Changed

- The Swift Package Index badges in the README show this fork instead of the upstream project.
- The Swift Package Index builds the documentation on macOS instead of iOS, so it includes the AppKit API.

## [1.1.1] - 2026-09-17

A documentation release. The API and the behaviour of the library are unchanged.

### Added

- The "Using a Scaled Font" article, which covers UIKit, AppKit and SwiftUI.
- The "Choosing Font Variants" article.
- Topic groups on the documentation landing page and on the `ScaledFont`, `FontDesign` and `FontWeight` pages.
- Documentation for `rawValue` and `init(rawValue:)` of `FontDesign` and `FontWeight`.
- How to list the available font names on macOS.

### Changed

- The documentation landing page describes every supported platform instead of iOS only.
- The pinned swift-docc-plugin is 1.5.0 instead of 1.0.0, so `swift package generate-documentation` works with current toolchains.

### Fixed

- The link to the typography specifications in the Human Interface Guidelines.
- The spelling of `adjustsFontForContentSizeCategory` in the documentation and the README.

## [1.1.0] - 2026-09-16

The first release of this fork.

### Added

- macOS 11 support. On macOS, `font(forTextStyle:)` takes an `NSFont.TextStyle` and returns an `NSFont`, and the SwiftUI modifiers work as they do on the other platforms. macOS has no Dynamic Type, so a custom font keeps the size from the style dictionary.
- System font entries in the style dictionary. Leave out `fontName` and `fontSize`, and use the `design` key (`default`, `serif` or `monospaced`) and the `weight` key (`regular` or `bold`).
- The `weight` key for custom fonts. `bold` uses the bold face of the same font family when the family has one that keeps the other style traits, such as italic or condensed, and otherwise keeps the configured font.
- `font(forTextStyle:design:weight:)` and `scaledFont(_:design:weight:)`, which override the variants of the style dictionary where you use a font.
- `ScaledFont.FontDesign` and `ScaledFont.FontWeight`. They are structures, so later versions can add designs and weights without breaking your code, and a `switch` over them needs a `default` case. A value that a version does not support is ignored.

### Changed

- A style dictionary entry without `fontName` and `fontSize` describes a system font. Previously such an entry made the whole style dictionary invalid. An entry with only one of the two keys still does.

### Upgrading From the Pre-release Branch

Apps that used the `codex/font-variant-overrides` branch before this release should note these differences:

- `FontDesign` and `FontWeight` changed from enumerations to structures, so a `switch` over them needs a `default` case. See [#2](https://github.com/gewill/ScaledFont/issues/2).
- If your app resolved the branch before commit `98de724`, this release also:
  - makes the whole style dictionary invalid again when an entry has only one of `fontName` and `fontSize`, instead of turning that text style into a system font;
  - scales system fonts once instead of twice at larger text sizes;
  - keeps an italic, condensed or already bold custom font when the weight is bold, instead of replacing it with another face;
  - applies the call-site variants in SwiftUI on iOS 13.

## [1.0.5] and Earlier

Released by the upstream project. See the [upstream releases](https://github.com/kharrison/ScaledFont/releases).

[Unreleased]: https://github.com/gewill/ScaledFont/compare/1.1.1...HEAD
[1.1.1]: https://github.com/gewill/ScaledFont/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/gewill/ScaledFont/compare/2ab843f...1.1.0
[1.0.5]: https://github.com/kharrison/ScaledFont/releases/tag/1.0.5
