//
//  WelcomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import SwiftUI

struct WelcomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.skipsEntranceAnimations) private var skipsEntranceAnimations
    @Environment(\.dimensions) private var dimensions
    @State private var hasEntered = false

    let signInViewModel: SignInViewModel

    private var isVisible: Bool {
        hasEntered || skipsEntranceAnimations
    }

    var body: some View {
        GeometryReader { geometry in
            if hasRoomSideBySide(in: geometry.size) {
                sideBySide
            } else {
                stacked
            }
        }
        .onAppear { enter() }
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
    }

    private func hasRoomSideBySide(in size: CGSize) -> Bool {
        let isWideEnough = size.width >= dimensions.welcomeSideBySideMinimumWidth
        let isTallEnough = size.height >= dimensions.welcomeSideBySideMinimumHeight
        return isWideEnough && isTallEnough
    }

    private func enter() {
        withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
            hasEntered = true
        }
    }

    private var sideBySide: some View {
        HStack(alignment: .center, spacing: dimensions.spaceXXXLarge) {
            pitch

            Spacer(minLength: 0)

            signInCard
                .frame(width: dimensions.welcomePanelWidth)
        }
        .padding(.horizontal, dimensions.spaceHuge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            WelcomeTrademark()
                .padding(.bottom, dimensions.spaceLarge)
        }
    }

    private var stacked: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXLarge) {
                pitch

                signInCard
                    .frame(maxWidth: dimensions.welcomePanelWidth)

                WelcomeTrademark()
            }
            .padding(dimensions.spaceXXLarge)
            .padding(.bottom, dimensions.spaceXLarge)
            .frame(maxWidth: .infinity)
        }
    }

    private var pitch: some View {
        WelcomePitch(features: signInViewModel.welcomeFeatures, isInPlace: isInPlace)
            .frame(maxWidth: dimensions.welcomePitchMaxWidth, alignment: .leading)
            .opacity(isVisible ? 1 : 0)
    }

    private var isInPlace: Bool {
        isVisible || reduceMotion
    }

    private var signInCard: some View {
        WelcomeSignInCard(step: signInViewModel.step, onRetry: { signInViewModel.retry() })
            .opacity(isVisible ? 1 : 0)
    }
}

#if DEBUG
#Preview {
    WelcomeView(
        signInViewModel: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
    .frame(width: 1100, height: 720)
    .background { SkyBackground() }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}

#Preview("Narrow window") {
    WelcomeView(
        signInViewModel: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
    .frame(width: 720, height: 720)
    .background { SkyBackground() }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
