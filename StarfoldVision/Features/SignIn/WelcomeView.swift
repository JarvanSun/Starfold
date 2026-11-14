//
//  WelcomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct WelcomeView: View {
    @Environment(\.dimensions) private var dimensions

    let signInViewModel: SignInViewModel

    var body: some View {
        HStack(alignment: .center, spacing: dimensions.spaceXXXLarge) {
            WelcomePitch(features: signInViewModel.welcomeFeatures)
                .frame(maxWidth: dimensions.readableTextMaximumWidth, alignment: .leading)

            Spacer(minLength: 0)

            WelcomeSignInCard(step: signInViewModel.step, onRetry: { signInViewModel.retry() })
        }
        .padding(.horizontal, dimensions.spaceHuge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) { WelcomeTrademark() }
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
    }
}

#if DEBUG
#Preview("Welcome") {
    WelcomeView(
        signInViewModel: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
}
#endif
