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
    @Environment(AppViewModel.self) private var app
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
}

// MARK: - Private

private extension RootView {
    @ViewBuilder
    var content: some View {
        switch streamPresenter {
        case let presenter?: root(presenter)
        case nil: LoadingView()
        }
    }

    func root(_ presenter: StreamPresenter) -> some View {
        @Bindable var presenter = presenter
        let presentationID = presenter.presentationID
        return ZStack {
            background(isStreamPresented: presenter.isPresented)

            page(presenter)
        }
        .sheet(isPresented: $isSignInPresented) { SignInHostView { SignInView(signIn: $0) } }
        .fullScreenCover(isPresented: streamCover(presenter, presentationID: presentationID)) {
            stream(presenter)
        }
        .sheet(isPresented: $presenter.isControllerPromptPresented) {
            ControllerPrompt(
                hasController: presenter.hasController,
                onCheckAgain: app.controllers.checkControllers,
                onPlay: presenter.startPromptedStream
            )
        }
        .alert("signIn.expired.title", isPresented: signInExpiredAlert(presenter)) {
            Button("signIn.expired.signIn") { endStreamAndSignIn(presenter) }

            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("signIn.expired.message")
        }
        .onChange(of: TopShelfSnapshot(app: app), initial: true) { _, snapshot in
            publish(snapshot)
        }
        .onOpenURL { url in open(url, presenter: presenter) }
        .onChange(of: app.sessionState) { followPendingLink(presenter) }
        .onChange(of: scenePhase, initial: true) { _, phase in apply(phase, presenter: presenter) }
    }

    @ViewBuilder
    func background(isStreamPresented: Bool) -> some View {
        switch isStreamPresented {
        case true: Color.black.ignoresSafeArea()
        case false: SkyBackground()
        }
    }

    @ViewBuilder
    func page(_ presenter: StreamPresenter) -> some View {
        switch app.sessionState {
        case .restoring: LoadingView()
        case .signedOut: SignInHostView { WelcomeView(signIn: $0) }
        case .signedIn: tabs(presenter)
        }
    }

    func tabs(_ presenter: StreamPresenter) -> some View {
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

    func stream(_ presenter: StreamPresenter) -> some View {
        StreamView(
            presenter: presenter,
            stream: app.stream,
            settings: app.settings,
            controllers: app.controllers
        )
        .untintedAppPalette()
        .alert("signIn.expired.title", isPresented: Bindable(app).isSignInExpired) {
            Button("signIn.expired.signIn") { signInAfterExpiry(presenter) }

            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("signIn.expired.message")
        }
    }

    func streamCover(_ presenter: StreamPresenter, presentationID: Int) -> Binding<Bool> {
        .init(
            get: { presenter.isPresented },
            set: { isPresented in
                if !isPresented { Task { await presenter.end(presentationID: presentationID) } }
            }
        )
    }

    func signInExpiredAlert(_ presenter: StreamPresenter) -> Binding<Bool> {
        .init(
            get: { app.isSignInExpired && !presenter.isPresented },
            set: { app.isSignInExpired = $0 }
        )
    }

    func createStreamPresenter() {
        guard streamPresenter == nil else { return }

        let presenter = StreamPresenter(app: app)
        app.onPlayRequest = { [weak presenter] in presenter?.start($0) }
        streamPresenter = presenter
    }

    func signInAfterExpiry(_ presenter: StreamPresenter) {
        app.isSignInExpired = false

        endStreamAndSignIn(presenter)
    }

    func endStreamAndSignIn(_ presenter: StreamPresenter) {
        Task {
            await presenter.end()

            isSignInPresented = true
        }
    }

    func publish(_ snapshot: TopShelfSnapshot?) {
        guard let snapshot, TopShelfStore().save(snapshot) else { return }

        TVTopShelfContentProvider.topShelfContentDidChange()
    }

    func open(_ url: URL, presenter: StreamPresenter) {
        pendingLink = TopShelfLink(url: url)

        followPendingLink(presenter)
    }

    func followPendingLink(_ presenter: StreamPresenter) {
        guard let link = pendingLink, app.sessionState != .restoring else { return }

        pendingLink = nil

        follow(link, presenter: presenter)
    }

    func follow(_ link: TopShelfLink, presenter: StreamPresenter) {
        guard app.sessionState == .signedIn, !presenter.isPresented else { return }

        switch link {
        case .game(let id, let name, shouldPlay: true):
            presenter.start(.cloud(titleID: id, name: name))
        case .game(let id, _, shouldPlay: false):
            selectedTab = .library

            libraryPath = app.library?.game(id: id).map { [$0] } ?? []
        case .console(let id, let name):
            selectedTab = .home

            presenter.start(.console(id: id, name: name))
        }
    }

    func apply(_ phase: ScenePhase, presenter: StreamPresenter) {
        presenter.moveToForeground(phase == .active)

        if phase != .active { app.controllers.routeInput(toGame: false) }

        if phase == .background { backgroundCleanup.end(presenter) }
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
