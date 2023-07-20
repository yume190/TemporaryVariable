// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let settings: [SwiftSetting] = [
    // .enableExperimentalFeature("Macros"),
    .enableExperimentalFeature("CodeItemMacros"),
    // ExtensionMacros
    // .unsafeFlags(["-Xfrontend", "-dump-macro-expansions"])
]

let package = Package(
    name: "TemporaryVariable",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "TemporaryVariable",
            targets: ["TemporaryVariable"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0-swift-DEVELOPMENT-SNAPSHOT-2023-07-10-a"
        ),
    ],
    targets: [
        .macro(
            name: "TemporaryVariablePlugin",
            dependencies:[
                .product(name: "SwiftSyntaxMacros", package:"swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("CodeItemMacros"),
            ]
        ),
        .target(
            name: "TemporaryVariable",
            dependencies: [
                "TemporaryVariablePlugin",
            ],
            swiftSettings: [
                .enableExperimentalFeature("CodeItemMacros"),
            ]
        ),
        .testTarget(
            name: "TemporaryVariableTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                // .product(name: "SwiftSyntaxMacros",package:"swift-syntax"),
                "TemporaryVariable",
            ]),
    ]
)



