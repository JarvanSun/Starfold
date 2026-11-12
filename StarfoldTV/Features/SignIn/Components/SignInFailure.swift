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
        VStack(spacing: dimensions.spaceXXLarge) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: dimensions.signInStatusSymbolPointSize))
                .foregroundStyle(Color.attention)

            Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center)

            Button("signIn.failure.retry", action: onRetry)
        }
        .frame(minHeight: dimensions.signInStatusMinimumHeight)
    }
}

#if DEBUG
#Preview {
    SignInFailure(message: "The sign-in code expired.") {}
}
#endif
