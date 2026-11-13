//
//  WelcomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct WelcomeView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.skipsEntranceAnimations) private var skipsEntranceAnimations
    @Environment(\.dimensions) private var dimensions
    @State private var hasEntered = false

    let signIn: SignInViewModel

    private var isVisible: Bool {
        hasEntered || skipsEntranceAnimations
    }

    var body: some View {
        GeometryReader { geometry in
            layout(in: geometry.size)
        }
        .onAppear { enter() }
        .task(id: signIn.attempt) { await signIn.run() }
    }

    @ViewBuilder
    private func layout(in size: CGSize) -> some View {
        if hasRoomSideBySide(in: size) {
            sideBySide
        } else if horizontalSizeClass == .regular {
            column
        } else if size.width > size.height {
            landscape
        } else {
            stacked
        }
    }

    private func hasRoomSideBySide(in size: CGSize) -> Bool {
        let isWideEnough = size.width >= dimensions.welcomeSideBySideMinimumWidth
        let isTallEnough = size.height >= dimensions.welcomeSideBySideMinimumHeight
        return isWideEnough && isTallEnough
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
    }

    private var column: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXXXLarge) {
                glyphAndSteps(glyphSize: dimensions.welcomeGlyphSize)

                signInSheet(placement: .center)
            }
            .frame(maxWidth: dimensions.welcomeSheetMaxWidth)
            .padding(dimensions.spaceXXLarge)
            .containerRelativeFrame([.horizontal, .vertical])
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
    }

    private var stacked: some View {
        ScrollView {
            glyphAndSteps(glyphSize: dimensions.welcomeGlyphSize)
                .padding(.horizontal, dimensions.spaceXXLarge)
                .padding(.bottom, dimensions.spaceXXLarge)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .safeAreaBar(edge: .bottom) {
            signInSheet(placement: .bottom)
        }
    }

    private var landscape: some View {
        glyphAndSteps(glyphSize: dimensions.welcomeCompactGlyphSize)
            .padding(.horizontal, dimensions.spaceXXLarge)
            .frame(maxHeight: .infinity, alignment: .top)
            .blur(radius: dimensions.welcomeBackdropBlur)
            .accessibilityHidden(true)
            .overlay {
                ScrollView {
                    signInSheet(placement: .center)
                        .containerRelativeFrame(.vertical)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
            }
    }

    private func signInSheet(placement: WelcomeSignInPlacement) -> some View {
        WelcomeSignInSheet(step: signIn.step, placement: placement, onRetry: { signIn.retry() })
            .frame(maxWidth: dimensions.welcomeSheetMaxWidth)
    }

    private func glyphAndSteps(glyphSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceHuge) {
            AppGlyph(size: glyphSize)

            WelcomeSteps()
        }
        .padding(.top, dimensions.spaceLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(isVisible ? 1 : 0)
    }

    private var pitch: some View {
        WelcomePitch(features: signIn.welcomeFeatures, isInPlace: isInPlace)
            .frame(maxWidth: dimensions.welcomePitchMaxWidth, alignment: .leading)
            .opacity(isVisible ? 1 : 0)
    }

    private var isInPlace: Bool {
        isVisible || reduceMotion
    }

    private var signInCard: some View {
        WelcomeSignInCard(step: signIn.step, onRetry: { signIn.retry() })
            .opacity(isVisible ? 1 : 0)
    }

    private func enter() {
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
    .background { SkyBackground() }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
