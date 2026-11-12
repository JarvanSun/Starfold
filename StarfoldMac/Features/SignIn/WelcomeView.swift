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

    let signIn: SignInViewModel

    var body: some View {
        GeometryReader { geometry in
            switch hasRoomSideBySide(in: geometry.size) {
            case true: sideBySide
            case false: stacked
            }
        }
        .onAppear { enter() }
        .task(id: signIn.attempt) { await signIn.run() }
    }
}

private extension WelcomeView {
    var isVisible: Bool {
        hasEntered || skipsEntranceAnimations
    }

    var isInPlace: Bool {
        isVisible || reduceMotion
    }

    var sideBySide: some View {
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

    var stacked: some View {
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

    var pitch: some View {
        WelcomePitch(features: signIn.welcomeFeatures, isInPlace: isInPlace)
            .frame(maxWidth: dimensions.welcomePitchMaxWidth, alignment: .leading)
            .opacity(isVisible ? 1 : 0)
    }

    var signInCard: some View {
        WelcomeSignInCard(step: signIn.step, onRetry: { signIn.retry() })
            .opacity(isVisible ? 1 : 0)
    }

    func hasRoomSideBySide(in size: CGSize) -> Bool {
        let isWideEnough = size.width >= dimensions.welcomeSideBySideMinimumWidth
        let isTallEnough = size.height >= dimensions.welcomeSideBySideMinimumHeight
        return isWideEnough && isTallEnough
    }

    func enter() {
        withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
            hasEntered = true
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView(
        signIn: PreviewObjectPool.signInViewModel(
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
        signIn: PreviewObjectPool.signInViewModel(
            phase: .waiting(PreviewObjectPool.deviceCodePrompt)
        )
    )
    .frame(width: 720, height: 720)
    .background { SkyBackground() }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
