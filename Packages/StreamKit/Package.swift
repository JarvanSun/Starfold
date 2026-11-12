// swift-tools-version: 6.2
//
//  Package.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
    .enableUpcomingFeature("MemberImportVisibility")
]

let package = Package(
    name: "StreamKit",
    platforms: [.macOS(.v26), .iOS(.v26), .visionOS(.v26), .tvOS(.v26)],
    products: [
        .library(name: "StreamKit", targets: ["StreamKit"])
    ],
    dependencies: [
        .package(path: "../XboxKit"),
        .package(
            url: "https://github.com/livekit/webrtc-xcframework.git",
            revision: "c73deceaddd9c07293871ae28f24d4326cc86d62"
        ),
    ],
    targets: [
        .target(
            name: "StreamKit",
            dependencies: [
                "XboxKit",
                .product(name: "LiveKitWebRTC", package: "webrtc-xcframework"),
            ],
            resources: [.process("Rendering/StreamShaders.metal")],
            swiftSettings: upcomingFeatures
        ),
        .testTarget(
            name: "StreamKitTests",
            dependencies: [
                "StreamKit",
                "XboxKit",
                .product(name: "LiveKitWebRTC", package: "webrtc-xcframework"),
            ],
            swiftSettings: upcomingFeatures
        ),
    ],
    swiftLanguageModes: [.v6]
)
