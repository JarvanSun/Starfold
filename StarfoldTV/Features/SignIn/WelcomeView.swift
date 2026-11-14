//
//  WelcomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeView: View {
    @Environment(\.dimensions) private var dimensions

    let signInViewModel: SignInViewModel

    var body: some View {
        HStack(spacing: dimensions.spaceHuge) {
            WelcomePitch(features: signInViewModel.welcomeFeatures)
                .frame(maxWidth: dimensions.welcomeIntroductionMaximumWidth, alignment: .leading)

            Spacer(minLength: 0)

            WelcomeSignInCard(step: signInViewModel.step, onRetry: { signInViewModel.retry() })
        }
        .padding(.horizontal, dimensions.spaceXXXLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) { WelcomeTrademark() }
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
    }
}

#if DEBUG
#Preview {
    WelcomeView(
        signInViewModel: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
}
#endif
