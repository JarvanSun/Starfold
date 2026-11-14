//
//  HomeHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct HomeHostView: View {
    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack {
            HomeView(homeViewModel: homeViewModel, libraryViewModel: libraryViewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AccountMenu(onAddAccount: onAddAccount)
                    }
                }
        }
    }
}

#if DEBUG
#Preview("Home") {
    HomeHostView(
        homeViewModel: PreviewObjectPool.homeViewModel(),
        libraryViewModel: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
