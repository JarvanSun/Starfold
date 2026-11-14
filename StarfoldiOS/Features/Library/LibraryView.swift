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
    @FocusState private var isFirstGameFocused: Bool

    let libraryViewModel: LibraryViewModel

    let onOpenGame: (CloudGame) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                ForEach(libraryViewModel.shelves) { shelfRow($0) }

                if !libraryViewModel.games.isEmpty {
                    AllGamesGrid(
                        libraryViewModel: libraryViewModel,
                        onOpenGame: onOpenGame,
                        firstTileFocus: libraryViewModel.shelves.isEmpty ? $isFirstGameFocused : nil
                    )
                }
            }
            .padding(.vertical, dimensions.spaceLarge)
        }
        .defaultFocus($isFirstGameFocused, true)
        .overlay { placeholder }
        .navigationTitle(Text("library.title"))
        .refreshable { await libraryViewModel.refresh() }
    }

    private func shelfRow(_ shelf: LibraryShelf) -> some View {
        ShelfRow(
            shelf: shelf,
            games: libraryViewModel.games(on: shelf),
            onPlay: { libraryViewModel.play($0) },
            onOpen: onOpenGame,
            firstTileFocus: shelf.id == libraryViewModel.shelves.first?.id
                ? $isFirstGameFocused : nil
        )
    }

    @ViewBuilder
    private var placeholder: some View {
        switch libraryViewModel.placeholder {
        case .noResults, nil: EmptyView()
        case let placeholder?: placeholderView(placeholder)
        }
    }

    private func placeholderView(_ placeholder: LibraryPlaceholder) -> some View {
        LibraryPlaceholderView(
            placeholder: placeholder,
            searchText: libraryViewModel.searchText,
            onRetry: { refresh() }
        )
        .pageMargins()
    }

    private func refresh() {
        Task { await libraryViewModel.refresh() }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Library", arguments: [LoadState.loaded, .loading, PreviewObjectPool.failedLoadState]) {
    state in
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(state: state)) { _ in }
            .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}

#Preview("No cloud gaming") {
    NavigationStack {
        LibraryView(libraryViewModel: PreviewObjectPool.libraryViewModel(access: .unavailable)) {
            _ in
        }
        .background { SkyBackground() }
    }
    .environment(\.colorScheme, .dark)
}
#endif
