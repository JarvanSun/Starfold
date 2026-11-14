//
//  SignedInTabView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignedInTabView: View {
    @State private var selection = SignedInTab.home

    let homeViewModel: HomeViewModel
    let libraryViewModel: LibraryViewModel

    let onAddAccount: () -> Void

    var body: some View {
        TabView(selection: $selection) {
            Tab("app.tab.home", systemImage: "house", value: SignedInTab.home) {
                HomeHostView(
                    homeViewModel: homeViewModel,
                    libraryViewModel: libraryViewModel,
                    onAddAccount: onAddAccount
                )
            }

            Tab("app.tab.cloudGaming", systemImage: "cloud", value: SignedInTab.library) {
                LibraryHostView(libraryViewModel: libraryViewModel)
            }

            Tab("app.tab.settings", systemImage: "gear", value: SignedInTab.settings) {
                SettingsHostView()
            }
        }
    }
}

#if DEBUG
#Preview("Tabs") {
    SignedInTabView(
        homeViewModel: PreviewObjectPool.homeViewModel(),
        libraryViewModel: PreviewObjectPool.libraryViewModel()
    ) {}
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
