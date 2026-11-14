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
    @State private var homePath: [HomeRoute] = []

    let homeViewModel: HomeViewModel
    @Bindable var libraryViewModel: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack(path: $homePath) {
            HomeView(homeViewModel: homeViewModel, libraryViewModel: libraryViewModel) {
                homePath.append(.cloudGaming)
            }
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

    private func gameDetail(_ game: CloudGame) -> some View {
        GameDetailView(gameDetailViewModel: libraryViewModel.detail(for: game))
            .background { SkyBackground() }
    }

    private var cloudGaming: some View {
        cloudGamingContent
            .background { SkyBackground() }
            .navigationTitle(Text("library.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortPicker(sort: $libraryViewModel.sort, choices: libraryViewModel.sortChoices)
                }
            }
            .searchable(
                text: $libraryViewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("search.field.prompt")
            )
            .textInputAutocapitalization(.never)
    }

    @ViewBuilder
    private var cloudGamingContent: some View {
        switch libraryViewModel.isSearching {
        case true:
            SearchResultsView(libraryViewModel: libraryViewModel, onOpenGame: { openGame($0) })
        case false: LibraryView(libraryViewModel: libraryViewModel, onOpenGame: { openGame($0) })
        }
    }

    private func openGame(_ game: CloudGame) {
        homePath.append(.game(game))
    }
}

#if DEBUG
#Preview("Home") {
    HomeHostView(
        homeViewModel: PreviewObjectPool.homeViewModel(),
        libraryViewModel: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
    .preferredColorScheme(.dark)
}
#endif
