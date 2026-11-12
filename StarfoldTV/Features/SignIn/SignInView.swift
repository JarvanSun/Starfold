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

    let signIn: SignInViewModel

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text("signIn.sheet.title").font(.largeTitle.bold())

            SignInPanel(step: signIn.step, onRetry: signIn.retry)

            Button("common.cancel") { dismiss() }
        }
        .padding(dimensions.spaceHuge)
        .task(id: signIn.attempt) { await signIn.run() }
        .onChange(of: signIn.shouldClose) { dismiss() }
        .onExitCommand { dismiss() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { dismiss() }
        }
    }
}

#if DEBUG
#Preview("Add account", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signIn: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
