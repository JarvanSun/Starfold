//
//  LibraryView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct LibraryView: View {
    @Environment(\.dimensions) private var dimensions

    let library: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                ForEach(library.shelves) { shelfRow($0) }

                if !library.games.isEmpty {
                    AllGamesGrid(library: library, onOpenGame: onOpenGame)
                }
            }
            .padding(.vertical, dimensions.spaceLarge)
        }
        .overlay { placeholder }
        .navigationTitle(Text("library.title"))
        .refreshable { await library.refresh() }
    }

    private func shelfRow(_ shelf: LibraryShelf) -> some View {
        ShelfRow(
            shelf: shelf,
            games: library.games(on: shelf),
            onPlay: { library.play($0) },
            onOpen: onOpenGame
        )
    }

    @ViewBuilder
    private var placeholder: some View {
        switch library.placeholder {
        case .noResults, nil: EmptyView()
        case let placeholder?: placeholderView(placeholder)
        }
    }

    private func placeholderView(_ placeholder: LibraryPlaceholder) -> some View {
        LibraryPlaceholderView(
            placeholder: placeholder,
            searchText: library.searchText,
            onRetry: { refresh() }
        )
        .pageMargins()
    }

    private func refresh() {
        Task { await library.refresh() }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Library", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(state: state)) { _ in }
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}

#Preview("No cloud gaming") {
    NavigationStack {
        LibraryView(library: PreviewObjectPool.libraryViewModel(access: .unavailable)) { _ in }
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif
