//
//  CloudAccessPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension CloudAccess {
    public var statusText: LocalizedStringResource {
        switch self {
        case .gamePass: .init("home.cloud.status.available", bundle: .module)
        case .freeToPlay: .init("home.cloud.status.freeToPlay", bundle: .module)
        case .unavailable: .init("home.cloud.status.unavailable", bundle: .module)
        case .unknown: .init("home.cloud.status.loading", bundle: .module)
        }
    }

    public var statusColor: Color {
        switch self {
        case .gamePass: .online
        case .freeToPlay: .standby
        case .unavailable, .unknown: .gray
        }
    }

    public var placeholderSymbol: String {
        switch self {
        case .unavailable: "cloud.slash.fill"
        case .gamePass, .freeToPlay, .unknown: "cloud.fill"
        }
    }

    public func cardSubtitle(gameCount: Int) -> LocalizedStringResource? {
        switch self {
        case .gamePass: .init("home.cloud.subtitle.gameCount \(gameCount)", bundle: .module)
        case .freeToPlay: .init("home.cloud.subtitle.freeToPlay", bundle: .module)
        case .unavailable: .init("home.cloud.subtitle.unavailable", bundle: .module)
        case .unknown: nil
        }
    }
}
