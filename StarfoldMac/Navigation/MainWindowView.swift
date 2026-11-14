//
//  MainWindowView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct MainWindowView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dimensions) private var dimensions
    @State private var homePath: [HomeRoute] = []
    @State private var isShowingSignIn = false

    var body: some View {
        NavigationStack(path: $homePath) {
            sessionContent
                .navigationDestination(for: HomeRoute.self) { destination(for: $0) }
                .background { SkyBackground() }
                .toolbar { MainToolbar(onShowSignIn: { showSignIn() }) }
        }
        .preferredColorScheme(.dark)
        .hiddenTitleWindowChrome()
        .sheet(isPresented: $isShowingSignIn) { SignInHostView { SignInView(signInViewModel: $0) } }
        .onChange(of: appViewModel.activeAccountID) { homePath.removeAll() }
        .alert(
            String(localized: "mainWindow.signInExpired.title"),
            isPresented: Bindable(appViewModel).isSignInExpired
        ) {
            signInExpiredActions
        } message: {
            Text("mainWindow.signInExpired.message")
        }
        .alert(
            appViewModel.homeViewModel?.powerProblem?.title ?? "",
            isPresented: isShowingPowerProblem,
            presenting: appViewModel.homeViewModel?.powerProblem
        ) { _ in
            Button(String(localized: "mainWindow.powerProblem.ok")) {}
        } message: { problem in
            Text(problem.message)
        }
    }

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        if let library = appViewModel.libraryViewModel {
            page(for: route, in: library).background { SkyBackground() }
        }
    }

    @ViewBuilder
    private func page(for route: HomeRoute, in library: LibraryViewModel) -> some View {
        switch route {
        case .cloudLibrary: LibraryView(libraryViewModel: library) { homePath.append(.game($0)) }
        case .game(let game):
            GameDetailView(gameDetailViewModel: library.makeGameDetailViewModel(for: game))
        }
    }

    private func showSignIn() {
        isShowingSignIn = true
    }

    @ViewBuilder
    private var sessionContent: some View {
        switch appViewModel.sessionState {
        case .restoring: restoringPlaceholder
        case .signedOut: SignInHostView { WelcomeView(signInViewModel: $0) }
        case .signedIn: signedInHome
        }
    }

    private var restoringPlaceholder: some View {
        HStack(spacing: dimensions.spaceXLarge) {
            SkeletonCard()

            SkeletonCard()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var signedInHome: some View {
        switch (appViewModel.homeViewModel, appViewModel.libraryViewModel) {
        case (let home?, let library?):
            HomeView(homeViewModel: home, libraryViewModel: library) {
                homePath.append(.cloudLibrary)
            }
        default: EmptyView()
        }
    }

    @ViewBuilder
    private var signInExpiredActions: some View {
        Button(String(localized: "mainWindow.signInExpired.signIn")) { showSignIn() }

        Button(String(localized: "mainWindow.signInExpired.notNow"), role: .cancel) {}
    }

    private var isShowingPowerProblem: Binding<Bool> {
        .init(
            get: { appViewModel.homeViewModel?.powerProblem != nil },
            set: { isShowing in
                if !isShowing {
                    appViewModel.homeViewModel?.powerProblem = nil
                }
            }
        )
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
