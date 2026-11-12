//
//  SignInPanel.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInPanel: View {
    let step: SignInStep
    let onRetry: () -> Void

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .animation(.smooth(duration: 0.35), value: step)
    }
}

private extension SignInPanel {
    @ViewBuilder
    var content: some View {
        switch step {
        case .preparing: SignInPlaceholder()
        case .code(let code): SignInCodeStep(code: code)
        case .progress(let progress): SignInProgressStatus(progress: progress)
        case .failure(let message): SignInFailure(message: message, onRetry: onRetry)
        }
    }
}

#if DEBUG
#Preview("Sign-in panel", arguments: PreviewObjectPool.signInSteps) { step in
    SignInPanel(step: step) {}
        .frame(width: 480)
        .padding()
}
#endif
