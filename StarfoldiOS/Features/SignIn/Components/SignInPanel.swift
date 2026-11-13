//
//  SignInPanel.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
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
            .sensoryFeedback(trigger: step) { _, step in step.arrivalFeedback }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .preparing:
            SignInPlaceholder()
                .transition(.opacity)
        case .code(let code):
            SignInCodeStep(code: code)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
        case .progress(let progress):
            SignInProgressStatus(progress: progress)
                .transition(.opacity)
        case .failure(let message):
            SignInFailure(message: message, onRetry: onRetry)
                .transition(.opacity)
        }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Sign-in panel", arguments: PreviewObjectPool.signInSteps) { step in
    SignInPanel(step: step) {}
        .padding()
        .frame(width: 420)
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif
