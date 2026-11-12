//
//  SignInFailure.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInFailure: View {
    @Environment(\.dimensions) private var dimensions

    let message: String

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: dimensions.messageSymbolSize))
                .foregroundStyle(Color.attention)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(String(localized: "signIn.failure.retry")) { onRetry() }
                .buttonStyle(.primary)
        }
        .frame(minHeight: dimensions.signInStatusMinimumHeight)
    }
}

#if DEBUG
#Preview {
    SignInFailure(message: "The sign-in code expired.") {}
        .padding()
        .frame(width: 420)
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif
