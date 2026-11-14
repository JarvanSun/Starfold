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
                .font(.system(size: dimensions.statusSymbolSize))
                .foregroundStyle(reason.symbolStyle)

            Text(reason.title)
                .font(.title.bold())

            if let advice {
                adviceText(advice)
            }

            HStack(spacing: dimensions.spaceLarge) {
                closeButton

                tryAgainButton
            }
        }
    }

    private func adviceText(_ advice: StreamFailureAdvice) -> some View {
        Text(advice.text)
            .font(.callout)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    private var closeButton: some View {
        Button("stream.ended.close") { onClose() }
            .controlSize(.large)
    }

    private var tryAgainButton: some View {
        Button {
            onTryAgain()
        } label: {
            Label("stream.ended.tryAgain", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#if DEBUG
#Preview {
    VStack {
        StreamEndedStatus(reason: .failed(""), advice: .consoleOffline, onClose: {}, onTryAgain: {})

        StreamEndedStatus(reason: .userStopped, advice: nil, onClose: {}, onTryAgain: {})
    }
    .padding()
}
#endif
