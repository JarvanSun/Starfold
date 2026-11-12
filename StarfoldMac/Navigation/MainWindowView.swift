//
//  MainWindowView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct MainWindowView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dimensions) private var dimensions
    @State private var path: [HomeRoute] = []
    @State private var isShowingSignIn = false

    var body: some View {
        NavigationStack(path: $path) {
            sessionContent
                .navigationDestination(for: HomeRoute.self) { destination(for: $0) }
                .background { SkyBackground() }
                .toolbar { MainToolbar(onShowSignIn: { showSignIn() }) }
        }
        .preferredColorScheme(.dark)
        .hiddenTitleWindowChrome()
        .sheet(isPresented: $isShowingSignIn) { SignInHostView { SignInView(signIn: $0) } }
        .onChange(of: app.activeAccountID) { path.removeAll() }
        .alert(
            String(localized: "mainWindow.signInExpired.title"),
            isPresented: Bindable(app).isSignInExpired
        ) {
            signInExpiredActions
        } message: {
            Text("mainWindow.signInExpired.message")
        }
        .alert(
            app.home?.powerProblem?.title ?? "",
            isPresented: isShowingPowerProblem,
            presenting: app.home?.powerProblem
        ) { _ in
            Button(String(localized: "mainWindow.powerProblem.ok")) {}
        } message: { problem in
            Text(problem.message)
        }
    }
}

private extension MainWindowView {
    @ViewBuilder
    var sessionContent: some View {
        switch app.sessionState {
        case .restoring: restoringPlaceholder
        case .signedOut: SignInHostView { WelcomeView(signIn: $0) }
        case .signedIn: signedInHome
        }
    }

    var restoringPlaceholder: some View {
        HStack(spacing: dimensions.spaceXLarge) {
            SkeletonCard()

            SkeletonCard()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    var signedInHome: some View {
        switch (app.home, app.library) {
        case (let home?, let library?):
            HomeView(home: home, library: library) { path.append(.cloudLibrary) }
        default: EmptyView()
        }
    }

    @ViewBuilder
    var signInExpiredActions: some View {
        Button(String(localized: "mainWindow.signInExpired.signIn")) { showSignIn() }

        Button(String(localized: "mainWindow.signInExpired.notNow"), role: .cancel) {}
    }

    var isShowingPowerProblem: Binding<Bool> {
        .init(
            get: { app.home?.powerProblem != nil },
            set: { isShowing in
                if !isShowing {
                    app.home?.powerProblem = nil
                }
            }
        )
    }

    @ViewBuilder
    func destination(for route: HomeRoute) -> some View {
        switch app.library {
        case let library?: page(for: route, in: library).background { SkyBackground() }
        case nil: EmptyView()
        }
    }

    @ViewBuilder
    func page(for route: HomeRoute, in library: LibraryViewModel) -> some View {
        switch route {
        case .cloudLibrary: LibraryView(library: library) { path.append(.game($0)) }
        case .game(let game): GameDetailView(detail: library.detail(for: game))
        }
    }

    func showSignIn() {
        isShowingSignIn = true
    }
}

private extension View {
    func hiddenTitleWindowChrome() -> some View {
        toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            .navigationTitle(Text(verbatim: AppInfo().displayName))
            .toolbar(removing: .title)
    }
}

#if DEBUG
#Preview("Signed in") {
    MainWindowView()
        .frame(width: 1180, height: 760)
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
        .environment(\.skipsEntranceAnimations, true)
}

#Preview("Signed out") {
    MainWindowView()
        .frame(width: 1180, height: 760)
        .environment(PreviewObjectPool.appViewModel(signedIn: false))
        .environment(\.skipsEntranceAnimations, true)
}
#endif
