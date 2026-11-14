// swift-tools-version: 6.2
//
//  Package.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import PackageDescription

let appSettings: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "StarfoldShared",
    defaultLocalization: "en",
    platforms: [.macOS(.v26), .iOS(.v26), .visionOS(.v26), .tvOS(.v26)],
    products: [
        .library(name: "StarfoldShared", targets: ["StarfoldShared"]),
        .library(name: "TopShelfKit", targets: ["TopShelfKit"]),
    ],
    dependencies: [.package(path: "../XboxKit"), .package(path: "../StreamKit")],
    targets: [
        .target(
            name: "StarfoldShared",
            dependencies: ["XboxKit", "StreamKit"],
            resources: [.process("Resources")],
            swiftSettings: appSettings
        ),
        .target(name: "TopShelfKit", swiftSettings: appSettings),
        .testTarget(
            name: "StarfoldSharedTests",
            dependencies: ["StarfoldShared", "XboxKit", "StreamKit"],
            swiftSettings: appSettings
        ),
        .testTarget(
            name: "TopShelfKitTests",
            dependencies: ["TopShelfKit"],
            swiftSettings: appSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
