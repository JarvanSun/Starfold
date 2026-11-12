//
//  SignInCodeStep.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import UIKit

struct SignInCodeStep: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dimensions) private var dimensions

    let code: SignInCode

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            signInButton

            enterCode

            waitingStatus
        }
    }
}

private extension SignInCodeStep {
    var signInButton: some View {
        Button(action: copyCodeAndOpenPage) {
            HStack(alignment: .center, spacing: dimensions.spaceSmall) {
                Image(systemName: "safari")

                Text("signIn.code.signIn")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
    }

    var enterCode: some View {
        VStack(spacing: dimensions.spaceMedium) {
            Text("signIn.code.instructions \(code.address)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            CodeBoxes(code: code)
        }
    }

    var waitingStatus: some View {
        HStack(spacing: dimensions.spaceSmall) {
            ProgressView()
                .controlSize(.small)

            Text("signIn.code.waiting")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }

    func copyCodeAndOpenPage() {
        UIPasteboard.general.string = code.text

        openURL(code.page)
    }
}

#if DEBUG
#Preview {
    SignInCodeStep(code: PreviewObjectPool.signInCode)
        .frame(width: 480)
        .padding()
}
#endif
