//
//  DeviceInfoHeader.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct DeviceInfoHeader {
    let quality: StreamQuality

    var json: String {
        let deviceInfo: [String: Any] = [
            "appInfo": [
                "env": [
                    "clientAppId": "www.xbox.com",
                    "clientAppType": "browser",
                    "clientAppVersion": "29.9.35",
                    "clientSdkVersion": "10.6.8",
                    "httpEnvironment": "prod",
                    "sdkInstallId": "",
                ]
            ],
            "dev": [
                "hw": [
                    "make": "Microsoft",
                    "model": "unknown",
                    "platformType": "desktop",
                    "sdktype": "web",
                ],
                "os": [
                    "name": quality.operatingSystemName,
                    "ver": "22631.2715",
                    "platform": "desktop",
                ],
                "displayInfo": [
                    "dimensions": ["widthInPixels": 4096, "heightInPixels": 2160],
                    "pixelDensity": ["dpiX": 1, "dpiY": 1],
                ],
                "browser": ["browserName": "edge", "browserVersion": "140.0.3485.66"],
            ],
        ]
        let encoded =
            (try? JSONSerialization.data(
                withJSONObject: deviceInfo,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )) ?? Data()
        return String(decoding: encoded, as: UTF8.self)
    }
}
