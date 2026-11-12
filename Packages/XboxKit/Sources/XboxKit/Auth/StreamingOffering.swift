//
//  StreamingOffering.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum StreamingOffering: String, Codable, Sendable, CaseIterable {
    case home = "xhome"
    case cloud = "xgpuweb"
    case cloudFreeToPlay = "xgpuwebf2p"

    var loginURL: URL {
        URL(string: "https://\(rawValue).gssv-play-prod.xboxlive.com/v2/login/user")!
    }
}
