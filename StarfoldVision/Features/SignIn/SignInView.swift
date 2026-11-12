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

    let signIn: SignInViewModel

    var body: some View {
        NavigationStack {
            SignInPanel(step: signIn.step, onRetry: { signIn.retry() })
                .padding(dimensions.spaceXXLarge)
                .frame(width: dimensions.signInSheetWidth, height: dimensions.signInSheetHeight)
                .navigationTitle("signIn.sheet.title")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("signIn.sheet.cancel") { dismiss() }
                    }
                }
        }
        .task(id: signIn.attempt) { await signIn.run() }
        .onChange(of: signIn.shouldClose) { dismiss() }
    }
}

#if DEBUG
#Preview("Add account", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signIn: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
