//
//  SignInView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dimensions) private var dimensions

    let signInViewModel: SignInViewModel

    var body: some View {
        NavigationStack {
            SignInPanel(step: signInViewModel.step, onRetry: { signInViewModel.retry() })
                .padding(dimensions.spaceXXLarge)
                .frame(width: dimensions.signInSheetWidth, height: dimensions.signInSheetHeight)
                .navigationTitle("signIn.sheet.title")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("signIn.sheet.cancel") { dismiss() }
                    }
                }
        }
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
        .onChange(of: signInViewModel.shouldClose) { dismiss() }
    }
}

#if DEBUG
#Preview("Add account", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signInViewModel: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
