//
//  SignInView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/30.
//

import StarfoldShared
import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dimensions) private var dimensions

    let signInViewModel: SignInViewModel

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text("signIn.sheet.title").font(.largeTitle.bold())

            SignInPanel(step: signInViewModel.step, onRetry: { signInViewModel.retry() })

            Button("common.cancel") { dismiss() }
        }
        .padding(dimensions.spaceHuge)
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
        .onChange(of: signInViewModel.shouldClose) { dismiss() }
        .onExitCommand { dismiss() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { dismiss() }
        }
    }
}

#if DEBUG
#Preview("Add account", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signInViewModel: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
