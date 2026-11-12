//
//  SignInHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInHostView<Screen: View>: View {
    @Environment(AppViewModel.self) private var app
    @State private var signIn: SignInViewModel?

    @ViewBuilder let screen: (SignInViewModel) -> Screen

    var body: some View {
        ZStack {
            switch signIn {
            case let signIn?: screen(signIn)
            case nil: Color.clear
            }
        }
        .onAppear { createSignIn() }
    }
}

private extension SignInHostView {
    func createSignIn() {
        guard signIn == nil else { return }

        signIn = app.makeSignInViewModel()
    }
}

#if DEBUG
#Preview("Add account") {
    SignInHostView { SignInView(signIn: $0) }
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
