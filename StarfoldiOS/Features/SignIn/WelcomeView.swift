//
//  WelcomeView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct WelcomeView: View {
    private enum Arrangement {
        case sideBySide, column, landscape, stacked
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.skipsEntranceAnimations) private var skipsEntranceAnimations
    @Environment(\.dimensions) private var dimensions
    @State private var hasEntered = false

    let signInViewModel: SignInViewModel

    private var isVisible: Bool {
        hasEntered || skipsEntranceAnimations
    }

    var body: some View {
        GeometryReader { geometry in
            layout(in: geometry.size)
        }
        .onAppear { enter() }
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
    }

    @ViewBuilder
    private func layout(in size: CGSize) -> some View {
        switch arrangement(in: size) {
        case .sideBySide: sideBySide
        case .column: column
        case .landscape: landscape
        case .stacked: stacked
        }
    }

    private func arrangement(in size: CGSize) -> Arrangement {
        let hasRoomSideBySide =
            size.width >= dimensions.welcomeSideBySideMinimumWidth
            && size.height >= dimensions.welcomeSideBySideMinimumHeight

        return switch (hasRoomSideBySide, horizontalSizeClass, size.width > size.height) {
        case (true, _, _): .sideBySide
        case (false, .regular, _): .column
        case (false, _, true): .landscape
        case (false, _, false): .stacked
        }
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

    private func glyphAndSteps(glyphSize: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceHuge) {
            AppGlyph(size: glyphSize)

            WelcomeSteps()
        }
        .padding(.top, dimensions.spaceLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(isVisible ? 1 : 0)
    }

    private func signInSheet(placement: WelcomeSignInPlacement) -> some View {
        WelcomeSignInSheet(
            step: signInViewModel.step,
            placement: placement,
            onRetry: { signInViewModel.retry() }
        )
        .frame(maxWidth: dimensions.welcomeSheetMaxWidth)
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

    private var pitch: some View {
        WelcomePitch(features: signInViewModel.welcomeFeatures, isInPlace: isInPlace)
            .frame(maxWidth: dimensions.welcomePitchMaxWidth, alignment: .leading)
            .opacity(isVisible ? 1 : 0)
    }

    private var isInPlace: Bool {
        isVisible || reduceMotion
    }

    private var signInCard: some View {
        signInSheet(placement: .center)
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
    .background { SkyBackground() }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
