//
//  WelcomeFeaturePresentation.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StarfoldShared

extension WelcomeFeature {
    var systemImage: String {
        switch self {
        case .console: "logo.xbox"
        case .cloudGaming: "cloud"
        case .platform: "bolt.fill"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .console: .init("welcome.feature.console.title")
        case .cloudGaming: WelcomeCopy.cloudGaming.title
        case .platform: .init("welcome.feature.mac.title")
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .console: .init("welcome.feature.console.detail")
        case .cloudGaming: WelcomeCopy.cloudGaming.detail
        case .platform: .init("welcome.feature.mac.detail")
        }
    }
}
