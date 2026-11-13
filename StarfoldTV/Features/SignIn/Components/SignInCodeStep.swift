//
//  SignInCodeStep.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SignInCodeStep: View {
    @Environment(\.dimensions) private var dimensions

    let code: SignInCode

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Text("signIn.code.scan").foregroundStyle(.secondary)

            QRCodeView(qrCode: code.qrCode)

            Text("signIn.code.enterAt \(code.address)").foregroundStyle(.secondary)

            userCode

            waitingStatus
        }
    }

    private var userCode: some View {
        Text(verbatim: code.text)
            .font(
                .system(
                    size: dimensions.signInUserCodePointSize,
                    weight: .bold,
                    design: .monospaced
                )
            )
            .accessibilityLabel(Text("signIn.code.accessibilityLabel \(code.spelledOut)"))
    }

    private var waitingStatus: some View {
        HStack(spacing: dimensions.spaceMedium) {
            ProgressView()

            Text("signIn.code.waiting")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }
}

#if DEBUG
#Preview {
    SignInCodeStep(code: PreviewObjectPool.signInCode)
}
#endif
