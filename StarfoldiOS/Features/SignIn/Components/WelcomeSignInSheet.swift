//
//  WelcomeSignInSheet.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct WelcomeSignInSheet: View {
    @Environment(\.palette) private var palette
    @Environment(\.dimensions) private var dimensions

    let step: SignInStep
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Text("welcome.panel.title")
                .font(.title2.bold())

            SignInPanel(step: step, onRetry: onRetry)
                .frame(maxWidth: dimensions.welcomePanelWidth)

            WelcomeTrademark()
        }
        .padding(.horizontal, dimensions.spaceXLarge)
        .padding(.top, dimensions.spaceXLarge)
        .padding(.bottom, dimensions.spaceSmall)
        .frame(maxWidth: .infinity)
        .background { surface }
    }

    private var surface: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: dimensions.cornerRadiusXXLarge,
            topTrailingRadius: dimensions.cornerRadiusXXLarge
        )
        let fillOpacity = 0.72

        return
            shape
            .fill(palette.nightRaised.color.opacity(fillOpacity))
            .background(.ultraThinMaterial, in: shape)
            .overlay { shape.strokeBorder(Color.cardStroke) }
            .ignoresSafeArea(edges: .bottom)
    }
}

#if DEBUG
#Preview {
    VStack {
        Spacer()

        WelcomeSignInSheet(step: .code(PreviewObjectPool.signInCode)) {}
    }
    .background { SkyBackground() }
    .environment(\.colorScheme, .dark)
}
#endif
