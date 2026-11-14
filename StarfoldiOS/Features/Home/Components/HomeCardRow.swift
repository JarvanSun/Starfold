//
//  HomeCardRow.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct HomeCardRow: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dimensions) private var dimensions

    let homeViewModel: HomeViewModel

    var firstCardFocus: FocusState<Bool>.Binding?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceLarge) {
                switch homeViewModel.consolesContent {
                case .loading: card(SkeletonCard(), index: 0)
                case .failed(let message): card(failedCard(message), index: 0)
                case .empty: card(NoConsolesCard(onRefresh: { refreshConsoles() }), index: 0)
                case .consoles: consoleCards
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, dimensions.spaceLarge)
        }
        .pageScrollMargins()
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    private func card(_ content: some View, index: Int) -> some View {
        sized(content)
            .cardEntrance(index: index)
    }

    @ViewBuilder
    private func sized(_ content: some View) -> some View {
        switch horizontalSizeClass {
        case .compact: content.containerRelativeFrame(.horizontal)
        default: content.frame(width: dimensions.homeCardWidth)
        }
    }

    private func failedCard(_ message: String) -> some View {
        ConsolesFailedCard(message: message, onRetry: { refreshConsoles() })
    }

    private func refreshConsoles() {
        Task { await homeViewModel.refreshConsoles() }
    }

    private var consoleCards: some View {
        ForEach(Array(homeViewModel.consoles.enumerated()), id: \.element.id) { index, console in
            card(
                focusTarget(
                    ConsoleCard(console: console, homeViewModel: homeViewModel),
                    index: index
                ),
                index: index
            )
        }
    }

    @ViewBuilder
    private func focusTarget(_ card: some View, index: Int) -> some View {
        switch (firstCardFocus, index) {
        case (let focus?, 0): card.focused(focus)
        default: card
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        HomeCardRow(homeViewModel: PreviewObjectPool.homeViewModel())

        HomeCardRow(homeViewModel: PreviewObjectPool.homeViewModel(consoles: []))
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
