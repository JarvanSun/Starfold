// swift-tools-version: 6.2
//
//  Package.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility")
]

let package = Package(
    name: "XboxKit",
    platforms: [.macOS(.v26), .iOS(.v26), .visionOS(.v26), .tvOS(.v26)],
    products: [
        .library(name: "XboxKit", targets: ["XboxKit"])
    ],
    targets: [
        .target(
            name: "XboxKit",
            swiftSettings: upcomingFeatures
        ),
        .testTarget(
            name: "XboxKitTests",
            dependencies: ["XboxKit"],
            swiftSettings: upcomingFeatures
        ),
    ],
    swiftLanguageModes: [.v6]
)
