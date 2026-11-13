//
//  SignInCodeStep.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import UIKit

struct SignInCodeStep: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dimensions) private var dimensions

    let code: SignInCode

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            enterCode

            signInButton

            waitingStatus
        }
    }

    private var enterCode: some View {
        VStack(spacing: dimensions.spaceSmall) {
            Text("signIn.code.instructions \(code.address)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            CodeBoxes(code: code)
        }
    }

    private var signInButton: some View {
        Button {
            copyCodeAndOpenPage()
        } label: {
            Label(String(localized: "signIn.code.signIn"), systemImage: "safari")
        }
        .buttonStyle(.primary)
        .keyboardShortcut(.defaultAction)
    }

    private func copyCodeAndOpenPage() {
        UIPasteboard.general.string = code.text

        openURL(code.page)
    }

    private var waitingStatus: some View {
        HStack(spacing: dimensions.spaceSmall) {
            ProgressView().controlSize(.small)

            Text("signIn.status.waiting")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview {
    SignInCodeStep(code: PreviewObjectPool.signInCode)
        .padding()
        .frame(width: 420)
        .background(Palette(.nebula).night.color)
        .environment(\.colorScheme, .dark)
}
#endif
