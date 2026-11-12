//
//  WelcomeCopyPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension WelcomeCopy {
    public var title: LocalizedStringResource {
        switch self {
        case .cloudGaming: .init("signIn.welcome.cloudGaming.title", bundle: .module)
        }
    }

    public var detail: LocalizedStringResource {
        switch self {
        case .cloudGaming: .init("signIn.welcome.cloudGaming.detail", bundle: .module)
        }
    }
}
