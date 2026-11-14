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
    let placement: WelcomeSignInPlacement
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Text("welcome.panel.title")
                .font(.title2.bold())

            SignInPanel(step: step, onRetry: onRetry)
                .frame(maxWidth: dimensions.welcomePanelWidth)
        }
        .padding(.horizontal, dimensions.spaceXLarge)
        .padding(.top, dimensions.spaceXLarge)
        .padding(.bottom, bottomPadding)
        .frame(maxWidth: .infinity)
        .background { surface }
    }

    private var bottomPadding: CGFloat {
        switch placement {
        case .bottom: dimensions.spaceLarge
        case .center: dimensions.spaceXLarge
        }
    }

    @ViewBuilder
    private var surface: some View {
        switch placement {
        case .bottom:
            material(
                in: UnevenRoundedRectangle(
                    topLeadingRadius: dimensions.cornerRadiusXXLarge,
                    topTrailingRadius: dimensions.cornerRadiusXXLarge
                )
            )
            .ignoresSafeArea(edges: .bottom)
        case .center:
            material(in: RoundedRectangle(cornerRadius: dimensions.cornerRadiusXXLarge))
        }
    }

    private func material(in shape: some InsettableShape) -> some View {
        let fillOpacity = 0.72

        return
            shape
            .fill(palette.nightRaised.color.opacity(fillOpacity))
            .background(.ultraThinMaterial, in: shape)
            .overlay { shape.strokeBorder(Color.cardStroke) }
    }
}

#if DEBUG
#Preview {
    VStack {
        Spacer()

        WelcomeSignInSheet(step: .code(PreviewObjectPool.signInCode), placement: .bottom) {}
    }
    .background { SkyBackground() }
    .environment(\.colorScheme, .dark)
}
#endif
