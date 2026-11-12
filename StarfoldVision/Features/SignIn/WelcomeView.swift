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

    let signIn: SignInViewModel

    var body: some View {
        HStack(alignment: .center, spacing: dimensions.spaceXXXLarge) {
            WelcomePitch(features: signIn.welcomeFeatures)
                .frame(maxWidth: dimensions.readableTextMaximumWidth, alignment: .leading)

            Spacer(minLength: 0)

            WelcomeSignInCard(step: signIn.step, onRetry: signIn.retry)
        }
        .padding(.horizontal, dimensions.spaceHuge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomLeading) { WelcomeTrademark() }
        .task(id: signIn.attempt) { await signIn.run() }
    }
}

#if DEBUG
#Preview("Welcome") {
    WelcomeView(
        signIn: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
}
#endif
