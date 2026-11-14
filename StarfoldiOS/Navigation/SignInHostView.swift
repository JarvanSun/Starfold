//
//  SignInHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SignInHostView<Screen: View>: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var signInViewModel: SignInViewModel?

    @ViewBuilder let screen: (SignInViewModel) -> Screen

    var body: some View {
        ZStack {
            switch signInViewModel {
            case let signInViewModel?: screen(signInViewModel)
            case nil: Color.clear
            }
        }
        .onAppear { createSignIn() }
    }

    private func createSignIn() {
        guard signInViewModel == nil else { return }

        signInViewModel = appViewModel.makeSignInViewModel()
    }
}

#if DEBUG
#Preview("Add account") {
    SignInHostView { SignInView(signInViewModel: $0) }
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
