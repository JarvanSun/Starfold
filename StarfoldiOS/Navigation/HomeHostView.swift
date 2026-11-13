//
//  HomeHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct HomeHostView: View {
    let home: HomeViewModel
    let library: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        NavigationStack {
            HomeView(home: home, library: library)
                .background { SkyBackground() }
                .navigationTitle(Text("app.tab.home"))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AccountMenu(onAddAccount: onAddAccount)
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
        }
    }
}

#if DEBUG
#Preview("Home") {
    HomeHostView(
        home: PreviewObjectPool.homeViewModel(),
        library: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
