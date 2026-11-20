//
//  QualityChoicePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import XboxKit

extension QualityChoice {
    public var consoleTitle: LocalizedStringResource {
        switch self {
        case .automatic: .init("settings.quality.automatic", bundle: .module)
        case .fixed(.standard): .init("settings.quality.standard", bundle: .module)
        case .fixed(.high): .init("settings.quality.high", bundle: .module)
        case .fixed(.highest): .init("settings.quality.console.highest", bundle: .module)
        case .fixed(.quadHD): .init("settings.quality.console.quadHD", bundle: .module)
        }
    }

    public var cloudTitle: LocalizedStringResource {
        switch self {
        case .automatic: .init("settings.quality.automatic", bundle: .module)
        case .fixed(.standard): .init("settings.quality.standard", bundle: .module)
        case .fixed(.high): .init("settings.quality.high", bundle: .module)
        case .fixed(.highest), .fixed(.quadHD):
            .init("settings.quality.cloud.highest", bundle: .module)
        }
    }
}
