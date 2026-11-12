//
//  SignInView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import SwiftUI

struct SignInView: View {
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dimensions) private var dimensions

    let signIn: SignInViewModel

    var body: some View {
        VStack(spacing: 0) {
            SignInSheetHeader { dismiss() }

            Divider().opacity(0.4)

            SignInPanel(step: signIn.step, onRetry: { signIn.retry() })
                .padding(dimensions.spaceXXLarge)
        }
        .frame(width: dimensions.signInSheetWidth)
        .background(palette.night.color)
        .preferredColorScheme(.dark)
        .task(id: signIn.attempt) { await signIn.run() }
        .onChange(of: signIn.shouldClose) { dismiss() }
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview("Sign-in sheet", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signIn: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
