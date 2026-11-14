//
//  StreamEndedStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamEndedStatus: View {
    @Environment(\.dimensions) private var dimensions

    let reason: StreamEndReason
    let advice: StreamFailureAdvice?

    let onClose: () -> Void
    let onTryAgain: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Image(systemName: reason.systemImage)
                .font(.system(size: dimensions.messageSymbolSize))
                .foregroundStyle(reason.symbolStyle)
                .symbolEffect(.bounce, value: reason)

            Text(reason.title)
                .font(.title2.bold())

            if let advice {
                adviceText(advice)
            }

            HStack(spacing: dimensions.spaceMedium) {
                closeButton

                tryAgainButton
            }
        }
    }

    private func adviceText(_ advice: StreamFailureAdvice) -> some View {
        Text(advice.text)
            .font(.callout)
            .foregroundStyle(.white.opacity(0.75))
            .multilineTextAlignment(.center)
            .textSelection(.enabled)
    }

    private var closeButton: some View {
        Button(String(localized: "stream.status.close")) { onClose() }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .keyboardShortcut(.cancelAction)
    }

    private var tryAgainButton: some View {
        Button {
            onTryAgain()
        } label: {
            Label(String(localized: "stream.status.tryAgain"), systemImage: "arrow.clockwise")
        }
        .buttonStyle(.primary)
        .keyboardShortcut(.defaultAction)
    }
}

#if DEBUG
#Preview {
    VStack {
        StreamEndedStatus(reason: .failed(""), advice: .consoleOffline, onClose: {}, onTryAgain: {})

        StreamEndedStatus(reason: .userStopped, advice: nil, onClose: {}, onTryAgain: {})
    }
    .padding()
    .foregroundStyle(.white)
    .background(.black)
}
#endif
