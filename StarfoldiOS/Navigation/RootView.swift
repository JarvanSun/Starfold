//
//  RootView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var isSignInPresented = false
    @State private var isStreamPresented = false
    @State private var backgroundStreamEnd = BackgroundStreamEnd()
    @State private var skyCanvasSize: CGSize?

    var body: some View {
        content
            .environment(\.skyCanvasSize, skyCanvasSize)
            .background { windowSizeReader }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $isSignInPresented) {
                SignInHostView { SignInView(signInViewModel: $0) }
            }
            .fullScreenCover(isPresented: $isStreamPresented) {
                endStream()
            } content: {
                StreamCoverView()
            }
            .alert("app.signInExpired.title", isPresented: signInExpiredAlert) {
                Button("app.signInExpired.signIn") { presentSignIn() }

                Button("app.signInExpired.notNow", role: .cancel) {}
            } message: {
                Text("app.signInExpired.message")
            }
            .onChange(of: appViewModel.streamPresentationRequest) { isStreamPresented = true }
            .onChange(of: scenePhase) { _, phase in apply(phase) }
    }

    private func endStream() {
        backgroundStreamEnd.end { await appViewModel.endStream() }
    }

    private func presentSignIn() {
        isSignInPresented = true
    }

    private func apply(_ phase: ScenePhase) {
        switch phase {
        case .background where isStreamPresented && isStreamUnderway:
            backgroundStreamEnd.endBeforeTimeRunsOut { await appViewModel.endStreamWhileAway() }
        case .active: backgroundStreamEnd.keepStream()
        default: break
        }
    }

    @ViewBuilder
    private var content: some View {
        switch (
            appViewModel.sessionState, appViewModel.homeViewModel, appViewModel.libraryViewModel
        ) {
        case (.signedIn, let homeViewModel?, let libraryViewModel?):
            signedInTabs(homeViewModel: homeViewModel, libraryViewModel: libraryViewModel)
        case (.signedOut, _, _): SignedOutView()
        case (.restoring, _, _), (.signedIn, _, _): restoring
        }
    }

    private func signedInTabs(homeViewModel: HomeViewModel, libraryViewModel: LibraryViewModel)
        -> some View
    {
        SignedInTabView(
            homeViewModel: homeViewModel,
            libraryViewModel: libraryViewModel,
            onAddAccount: { presentSignIn() }
        )
    }

    private var windowSizeReader: some View {
        Color.clear
            .onGeometryChange(for: CGSize.self) { proxy in
                CGSize(
                    width: proxy.size.width + proxy.safeAreaInsets.leading
                        + proxy.safeAreaInsets.trailing,
                    height: proxy.size.height + proxy.safeAreaInsets.top
                        + proxy.safeAreaInsets.bottom
                )
            } action: {
                skyCanvasSize = $0
            }
    }

    private var restoring: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { SkyBackground() }
    }

    private var signInExpiredAlert: Binding<Bool> {
        .init(
            get: { appViewModel.isSignInExpired && !isStreamPresented },
            set: { appViewModel.isSignInExpired = $0 }
        )
    }

    private var isStreamUnderway: Bool {
        switch appViewModel.streamViewModel?.status {
        case .ended?, nil: false
        case .connecting?, .queued?: true
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
