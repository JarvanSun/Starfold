//
//  SignInStepPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI

extension SignInStep {
    public var arrivalFeedback: SensoryFeedback? {
        switch self {
        case .progress(.signedIn): .success
        case .failure: .error
        case .preparing, .code, .progress(.signingIn): nil
        }
    }
}
