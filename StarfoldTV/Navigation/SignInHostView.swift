//
//  SignInHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
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
            case let signIn?: screen(signIn)
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
#Preview {
    SignInHostView { SignInView(signInViewModel: $0) }
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
