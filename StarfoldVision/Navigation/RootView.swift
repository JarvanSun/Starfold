//
//  RootView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.pushWindow) private var pushWindow
    @State private var isSignInPresented = false

    var body: some View {
        content
            .sheet(isPresented: $isSignInPresented) {
                SignInHostView { SignInView(signInViewModel: $0) }
            }
            .alert("app.signInExpired.title", isPresented: Bindable(appViewModel).isSignInExpired) {
                Button("app.signInExpired.signIn") { presentSignIn() }

                Button("app.signInExpired.notNow", role: .cancel) {}
            } message: {
                Text("app.signInExpired.message")
            }
            .onChange(of: appViewModel.streamPresentationRequest) { showStreamWindow() }
    }

    private func presentSignIn() {
        isSignInPresented = true
    }

    private func showStreamWindow() {
        pushWindow(id: SceneID.stream.rawValue)
    }

    @ViewBuilder
    private var content: some View {
        switch (
            appViewModel.sessionState, appViewModel.homeViewModel, appViewModel.libraryViewModel
        ) {
        case (.signedIn, let home?, let library?): signedInTabs(home: home, library: library)
        case (.signedOut, _, _): signedOutTabs
        case (.restoring, _, _), (.signedIn, _, _): ProgressView()
        }
    }

    private func signedInTabs(home: HomeViewModel, library: LibraryViewModel) -> some View {
        SignedInTabView(
            homeViewModel: home,
            libraryViewModel: library,
            onAddAccount: { presentSignIn() }
        )
    }

    private var signedOutTabs: some View {
        TabView {
            Tab("app.tab.signIn", systemImage: "person.crop.circle") {
                SignInHostView { WelcomeView(signInViewModel: $0) }
            }

            Tab("app.tab.settings", systemImage: "gear") {
                SettingsHostView()
            }
        }
    }
}

#if DEBUG
#Preview("Signed in") {
    RootView()
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}

#Preview("Signed out") {
    RootView()
        .environment(PreviewObjectPool.appViewModel(signedIn: false))
}
#endif
