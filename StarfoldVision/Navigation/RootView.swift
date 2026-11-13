//
//  RootView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.pushWindow) private var pushWindow
    @State private var isSignInPresented = false

    var body: some View {
        content
            .sheet(isPresented: $isSignInPresented) { SignInHostView { SignInView(signIn: $0) } }
            .alert("app.signInExpired.title", isPresented: Bindable(app).isSignInExpired) {
                Button("app.signInExpired.signIn") { presentSignIn() }

                Button("app.signInExpired.notNow", role: .cancel) {}
            } message: {
                Text("app.signInExpired.message")
            }
            .onChange(of: app.streamPresentationRequest) { showStreamWindow() }
    }

    @ViewBuilder
    private var content: some View {
        switch (app.sessionState, app.home, app.library) {
        case (.signedIn, let home?, let library?): signedInTabs(home: home, library: library)
        case (.signedOut, _, _): signedOutTabs
        case (.restoring, _, _), (.signedIn, _, _): ProgressView()
        }
    }

    private func signedInTabs(home: HomeViewModel, library: LibraryViewModel) -> some View {
        SignedInTabView(home: home, library: library, onAddAccount: { presentSignIn() })
    }

    private func presentSignIn() {
        isSignInPresented = true
    }

    private var signedOutTabs: some View {
        TabView {
            Tab("app.tab.signIn", systemImage: "person.crop.circle") {
                SignInHostView { WelcomeView(signIn: $0) }
            }

            Tab("app.tab.settings", systemImage: "gear") {
                SettingsHostView()
            }
        }
    }

    private func showStreamWindow() {
        pushWindow(id: SceneID.stream.rawValue)
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
