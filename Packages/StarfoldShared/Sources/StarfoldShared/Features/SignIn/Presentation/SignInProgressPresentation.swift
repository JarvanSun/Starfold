//
//  SignInProgressPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension SignInProgress {
    public var systemImage: String {
        switch self {
        case .signingIn: "person.crop.circle"
        case .signedIn: "checkmark.circle.fill"
        }
    }

    public var title: LocalizedStringResource {
        switch self {
        case .signingIn: .init("signIn.progress.signingIn", bundle: .module)
        case .signedIn: .init("signIn.progress.signedIn", bundle: .module)
        }
    }
}
