//
//  WelcomeSignInCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeSignInCard: View {
    @Environment(\.dimensions) private var dimensions

    let step: SignInStep

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text("welcome.signIn.title").font(.title2.bold())

            SignInPanel(step: step, onRetry: onRetry)
        }
        .padding(dimensions.spaceHuge)
        .frame(width: dimensions.welcomePanelWidth)
        .background(Color.cardFill, in: .rect(cornerRadius: dimensions.cornerRadiusXXLarge))
    }
}

#if DEBUG
#Preview {
    WelcomeSignInCard(step: .code(PreviewObjectPool.signInCode)) {}
}
#endif
