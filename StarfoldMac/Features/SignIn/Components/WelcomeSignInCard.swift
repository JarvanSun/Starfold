//
//  WelcomeSignInCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct WelcomeSignInCard: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let step: SignInStep

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Text("welcome.panel.title")
                .font(.title2.bold())

            SignInPanel(step: step, onRetry: onRetry)
        }
        .padding(dimensions.spaceXXLarge)
        .background(
            palette.nightRaised.color.opacity(0.72),
            in: .rect(cornerRadius: dimensions.cornerRadiusXXLarge)
        )
        .background(.ultraThinMaterial, in: .rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .overlay {
            RoundedRectangle(cornerRadius: dimensions.cornerRadiusXXLarge)
                .strokeBorder(Color.cardStroke)
        }
    }
}

#if DEBUG
#Preview {
    WelcomeSignInCard(step: .code(PreviewObjectPool.signInCode)) {}
        .frame(width: 420)
        .padding()
        .background { SkyBackground() }
        .environment(\.colorScheme, .dark)
}
#endif
