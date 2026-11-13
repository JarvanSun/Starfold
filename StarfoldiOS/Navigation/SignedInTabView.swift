//
//  SignedInTabView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SignedInTabView: View {
    @State private var selection = SignedInTab.home

    let home: HomeViewModel
    let library: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        TabView(selection: $selection) {
            Tab("app.tab.home", systemImage: "house", value: SignedInTab.home) {
                HomeHostView(home: home, library: library, onAddAccount: onAddAccount)
            }

            Tab("app.tab.cloudGaming", systemImage: "cloud", value: SignedInTab.library) {
                LibraryHostView(library: library)
            }

            Tab("app.tab.settings", systemImage: "gear", value: SignedInTab.settings) {
                SettingsHostView(onAddAccount: onAddAccount)
            }

            Tab(value: SignedInTab.search, role: .search) {
                SearchHostView(library: library)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#if DEBUG
#Preview("Tabs") {
    SignedInTabView(
        home: PreviewObjectPool.homeViewModel(),
        library: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
    .preferredColorScheme(.dark)
}
#endif
