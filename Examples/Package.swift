// swift-tools-version:5.7
//
// TextSizeDemo is a macOS app that shows the in-app text size of
// ScaledFont. Run it from this folder:
//
//     swift run TextSizeDemo
//
// The style dictionaries in this folder are the resources of the app.

import PackageDescription

let package = Package(
    name: "Examples",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // The name keeps the product reference working when the
        // repository folder has another name, such as the
        // ScaledFont-main folder of a downloaded archive.
        .package(name: "ScaledFont", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "TextSizeDemo",
            dependencies: [
                .product(name: "ScaledFont", package: "ScaledFont")
            ],
            path: ".",
            exclude: ["README.md", "NotoSerif.plist"],
            sources: ["TextSizeDemo"],
            resources: [
                .process("Futura.plist"),
                .process("Noteworthy.plist"),
                .process("SystemFonts.plist")
            ]
        )
    ]
)
