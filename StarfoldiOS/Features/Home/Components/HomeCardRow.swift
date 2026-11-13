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

    let home: HomeViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceLarge) {
                switch home.consolesContent {
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

    private func failedCard(_ message: String) -> some View {
        ConsolesFailedCard(message: message, onRetry: { refreshConsoles() })
    }

    private func refreshConsoles() {
        Task { await home.refreshConsoles() }
    }

    private var consoleCards: some View {
        ForEach(Array(home.consoles.enumerated()), id: \.element.id) { index, console in
            card(ConsoleCard(console: console, home: home), index: index)
        }
    }

    @ViewBuilder
    private func card(_ content: some View, index: Int) -> some View {
        switch horizontalSizeClass {
        case .compact:
            content
                .containerRelativeFrame(.horizontal)
                .cardEntrance(index: index)
        default:
            content
                .frame(width: dimensions.homeCardWidth)
                .cardEntrance(index: index)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        HomeCardRow(home: PreviewObjectPool.homeViewModel())

        HomeCardRow(home: PreviewObjectPool.homeViewModel(consoles: []))
    }
    .environment(\.skipsEntranceAnimations, true)
    .environment(\.colorScheme, .dark)
}
#endif
