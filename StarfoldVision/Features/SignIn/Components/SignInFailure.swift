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
                .font(.system(size: dimensions.statusSymbolSize))
                .foregroundStyle(Color.attention)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("signIn.failure.retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
#Preview {
    SignInFailure(message: "The sign-in code expired.") {}
        .frame(width: 480)
        .padding()
}
#endif
