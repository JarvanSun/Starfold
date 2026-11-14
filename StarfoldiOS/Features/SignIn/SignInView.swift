//
//  SignInView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SignInView: View {
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dimensions) private var dimensions

    let signInViewModel: SignInViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                SignInPanel(step: signInViewModel.step, onRetry: { signInViewModel.retry() })
                    .padding(dimensions.spaceXLarge)
                    .frame(maxWidth: dimensions.welcomePanelWidth)
                    .frame(maxWidth: .infinity)
            }
            .background(palette.night.color)
            .navigationTitle(Text("signIn.sheet.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
        .task(id: signInViewModel.attempt) { await signInViewModel.run() }
        .onChange(of: signInViewModel.shouldClose) { dismiss() }
    }
}

#if DEBUG
@available(iOS 27, *)
#Preview("Sign-in sheet", arguments: PreviewObjectPool.signInPhases) { phase in
    SignInView(signInViewModel: PreviewObjectPool.signInViewModel(phase: phase))
}
#endif
