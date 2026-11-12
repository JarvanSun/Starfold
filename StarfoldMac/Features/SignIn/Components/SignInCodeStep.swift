//
//  SignInCodeStep.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import SwiftUI

struct SignInCodeStep: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dimensions) private var dimensions

    let code: SignInCode

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Text("signIn.qrCode.title")
                .font(.callout)
                .foregroundStyle(.secondary)

            QRCodeView(qrCode: code.qrCode)

            enterCode

            openLinkButton

            waitingStatus
        }
    }
}

private extension SignInCodeStep {
    var enterCode: some View {
        VStack(spacing: dimensions.spaceSmall) {
            Text("signIn.code.instructions \(code.address)")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            CodeBoxes(code: code)
        }
    }

    var openLinkButton: some View {
        Button {
            copyCodeAndOpenPage()
        } label: {
            Label(String(localized: "signIn.openLink"), systemImage: "safari")
        }
        .buttonStyle(.primary)
        .keyboardShortcut(.defaultAction)
    }

    var waitingStatus: some View {
        HStack(spacing: dimensions.spaceSmall) {
            ProgressView().controlSize(.small)

            Text("signIn.status.waiting")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    func copyCodeAndOpenPage() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code.text, forType: .string)

        openURL(code.page)
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
