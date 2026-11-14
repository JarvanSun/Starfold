//
//  RootView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI
import TVServices
import TopShelfKit
import XboxKit

struct RootView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var streamPresenter: StreamPresenter?
    @State private var selectedTab = RootTab.home
    @State private var libraryPath: [CloudGame] = []
    @State private var pendingLink: TopShelfLink?
    @State private var isSignInPresented = false
    @State private var backgroundCleanup = BackgroundStreamCleanup()

    var body: some View {
        content
            .preferredColorScheme(.dark)
            .task { createStreamPresenter() }
    }

    @ViewBuilder
    private var content: some View {
        switch streamPresenter {
        case let presenter?: root(presenter)
        case nil: LoadingView()
        }
    }

    private func root(_ presenter: StreamPresenter) -> some View {
        @Bindable var presenter = presenter
        let presentationID = presenter.presentationID
        return ZStack {
            background(isStreamPresented: presenter.isPresented)

            page(presenter)
        }
        .sheet(isPresented: $isSignInPresented) {
            SignInHostView { SignInView(signInViewModel: $0) }
        }
        .fullScreenCover(isPresented: streamCover(presenter, presentationID: presentationID)) {
            stream(presenter)
        }
        .sheet(isPresented: $presenter.isControllerPromptPresented) {
            ControllerPrompt(
                hasController: presenter.hasController,
                onCheckAgain: { appViewModel.controllerHub.checkControllers() },
                onPlay: { presenter.startPromptedStream() }
            )
        }
        .alert("signIn.expired.title", isPresented: signInExpiredAlert(presenter)) {
            Button("signIn.expired.signIn") { endStreamAndSignIn(presenter) }

            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("signIn.expired.message")
        }
        .onChange(of: TopShelfSnapshot(appViewModel: appViewModel), initial: true) { _, snapshot in
            publish(snapshot)
        }
        .onOpenURL { url in open(url, presenter: presenter) }
        .onChange(of: appViewModel.sessionState) { followPendingLink(presenter) }
        .onChange(of: scenePhase, initial: true) { _, phase in apply(phase, presenter: presenter) }
    }

    @ViewBuilder
    private func page(_ presenter: StreamPresenter) -> some View {
        switch appViewModel.sessionState {
        case .restoring: LoadingView()
        case .signedOut: SignInHostView { WelcomeView(signInViewModel: $0) }
        case .signedIn: tabs(presenter)
        }
    }

    private func tabs(_ presenter: StreamPresenter) -> some View {
        TabView(selection: $selectedTab) {
            Tab("app.tab.home", systemImage: "house", value: RootTab.home) {
                HomeHostView(onBrowse: { selectedTab = .library })
            }

            Tab("app.tab.library", systemImage: "cloud", value: RootTab.library) {
                LibraryHostView(path: $libraryPath)
            }

            Tab("app.tab.settings", systemImage: "gear", value: RootTab.settings) {
                SettingsHostView(onAddAccount: { isSignInPresented = true })
            }

            Tab(value: RootTab.search, role: .search) {
                SearchHostView()
            }
        }
    }

    private func streamCover(_ presenter: StreamPresenter, presentationID: Int) -> Binding<Bool> {
        .init(
            get: { presenter.isPresented },
            set: { isPresented in
                if !isPresented { Task { await presenter.end(presentationID: presentationID) } }
            }
        )
    }

    private func stream(_ presenter: StreamPresenter) -> some View {
        StreamView(
            streamPresenter: presenter,
            streamViewModel: appViewModel.streamViewModel,
            settingsViewModel: appViewModel.settingsViewModel,
            controllerHub: appViewModel.controllerHub
        )
        .appPalette()
        .alert("signIn.expired.title", isPresented: Bindable(appViewModel).isSignInExpired) {
            Button("signIn.expired.signIn") { signInAfterExpiry(presenter) }

            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("signIn.expired.message")
        }
    }

    private func signInAfterExpiry(_ presenter: StreamPresenter) {
        appViewModel.isSignInExpired = false

        endStreamAndSignIn(presenter)
    }

    private func endStreamAndSignIn(_ presenter: StreamPresenter) {
        Task {
            await presenter.end()

            isSignInPresented = true
        }
    }

    private func signInExpiredAlert(_ presenter: StreamPresenter) -> Binding<Bool> {
        .init(
            get: { appViewModel.isSignInExpired && !presenter.isPresented },
            set: { appViewModel.isSignInExpired = $0 }
        )
    }

    private func publish(_ snapshot: TopShelfSnapshot?) {
        guard let snapshot, TopShelfStore().save(snapshot) else { return }

        TVTopShelfContentProvider.topShelfContentDidChange()
    }

    private func open(_ url: URL, presenter: StreamPresenter) {
        pendingLink = TopShelfLink(url: url)

        followPendingLink(presenter)
    }

    private func followPendingLink(_ presenter: StreamPresenter) {
        guard let link = pendingLink, appViewModel.sessionState != .restoring else { return }

        pendingLink = nil

        follow(link, presenter: presenter)
    }

    private func follow(_ link: TopShelfLink, presenter: StreamPresenter) {
        guard appViewModel.sessionState == .signedIn, !presenter.isPresented else { return }

        switch link {
        case .game(let id, let name, shouldPlay: true):
            presenter.start(.cloud(titleID: id, name: name))
        case .game(let id, _, shouldPlay: false):
            selectedTab = .library

            libraryPath = appViewModel.libraryViewModel?.game(id: id).map { [$0] } ?? []
        case .console(let id, let name):
            selectedTab = .home

            presenter.start(.console(id: id, name: name))
        }
    }

    private func apply(_ phase: ScenePhase, presenter: StreamPresenter) {
        presenter.moveToForeground(phase == .active)

        if phase != .active { appViewModel.controllerHub.routeInput(toGame: false) }

        if phase == .background { backgroundCleanup.end(presenter) }
    }

    @ViewBuilder
    private func background(isStreamPresented: Bool) -> some View {
        switch isStreamPresented {
        case true: Color.black.ignoresSafeArea()
        case false: SkyBackground()
        }
    }

    private func createStreamPresenter() {
        guard streamPresenter == nil else { return }

        let presenter = StreamPresenter(appViewModel: appViewModel)
        appViewModel.onPlayRequest = { [weak presenter] in presenter?.start($0) }
        streamPresenter = presenter
    }
}

// MARK: - Previews

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
