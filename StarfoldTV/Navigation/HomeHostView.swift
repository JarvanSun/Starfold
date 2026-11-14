//
//  HomeHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct HomeHostView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var path: [CloudGame] = []

    let onBrowse: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onChange(of: appViewModel.activeAccountID) { path.removeAll() }
    }

    @ViewBuilder
    private var content: some View {
        switch (appViewModel.homeViewModel, appViewModel.libraryViewModel) {
        case (let home?, let library?): page(home: home, library: library)
        default: LoadingView()
        }
    }

    private func page(home: HomeViewModel, library: LibraryViewModel) -> some View {
        HomeView(homeViewModel: home, libraryViewModel: library, onBrowse: onBrowse)
            .navigationDestination(for: CloudGame.self) { game in
                GameDetailView(gameDetailViewModel: library.detail(for: game))
            }
    }
}

#if DEBUG
#Preview {
    HomeHostView(onBrowse: {})
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
