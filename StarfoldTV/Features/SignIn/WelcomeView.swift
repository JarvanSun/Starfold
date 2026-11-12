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

    let signIn: SignInViewModel

    var body: some View {
        HStack(spacing: dimensions.spaceHuge) {
            WelcomePitch(features: signIn.welcomeFeatures)
                .frame(maxWidth: dimensions.welcomeIntroductionMaximumWidth, alignment: .leading)

            Spacer(minLength: 0)

            WelcomeSignInCard(step: signIn.step, onRetry: signIn.retry)
        }
        .padding(.horizontal, dimensions.spaceXXXLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) { WelcomeTrademark() }
        .task(id: signIn.attempt) { await signIn.run() }
    }
}

#if DEBUG
#Preview {
    WelcomeView(
        signIn: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
}
#endif
