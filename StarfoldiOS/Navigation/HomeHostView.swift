//
//  HomeHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct HomeHostView: View {
    @State private var path: [HomeRoute] = []

    let home: HomeViewModel
    @Bindable var library: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(home: home, library: library) { path.append(.cloudGaming) }
                .background { SkyBackground() }
                .navigationTitle(Text("app.tab.home"))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AccountMenu(onAddAccount: onAddAccount)
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                .navigationDestination(for: HomeRoute.self) { destination(for: $0) }
        }
    }

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        switch route {
        case .cloudGaming: cloudGaming
        case .game(let game): gameDetail(game)
        }
    }

    private var cloudGaming: some View {
        cloudGamingContent
            .background { SkyBackground() }
            .navigationTitle(Text("library.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortPicker(sort: $library.sort, choices: library.sortChoices)
                }
            }
            .searchable(
                text: $library.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("search.field.prompt")
            )
            .textInputAutocapitalization(.never)
    }

    @ViewBuilder
    private var cloudGamingContent: some View {
        switch library.isSearching {
        case true: SearchResultsView(library: library, onOpenGame: { openGame($0) })
        case false: LibraryView(library: library, onOpenGame: { openGame($0) })
        }
    }

    private func openGame(_ game: CloudGame) {
        path.append(.game(game))
    }

    private func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(detail: library.detail(for: game))
            .background { SkyBackground() }
    }
}

#if DEBUG
#Preview("Home") {
    HomeHostView(
        home: PreviewObjectPool.homeViewModel(),
        library: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
    .preferredColorScheme(.dark)
}
#endif
