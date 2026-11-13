//
//  ConsoleShelf.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct ConsoleShelf: View {
    @Environment(\.dimensions) private var dimensions

    let home: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceLarge) {
            Text("home.consoles.title")
                .font(.title2.bold())

            switch home.consolesContent {
            case .loading: ConsoleSkeletons()
            case .failed(let message):
                ConsolesFailedMessage(message: message, onRetry: { refresh() })
            case .empty: NoConsolesMessage(onRefresh: { refresh() })
            case .consoles: cards
            }
        }
    }

    private func refresh() {
        Task { await home.refreshConsoles() }
    }

    private var cards: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceXLarge) {
                ForEach(home.consoles) { console in
                    ConsoleCard(console: console, home: home)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

#if DEBUG
#Preview("Console shelf") {
    VStack(alignment: .leading) {
        ConsoleShelf(home: PreviewObjectPool.homeViewModel())

        ConsoleShelf(home: PreviewObjectPool.homeViewModel(state: .loading))
    }
    .padding()
}
#endif
