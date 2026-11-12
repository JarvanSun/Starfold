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

    let onRetry: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text(reason.title)
                .font(.title2)

            switch advice {
            case let advice?: adviceText(advice)
            case nil: EmptyView()
            }

            Button("stream.ended.retry") { onRetry() }
                .buttonStyle(.borderedProminent)

            Button("stream.ended.back") { onEnd() }
        }
    }
}

private extension StreamEndedStatus {
    func adviceText(_ advice: StreamFailureAdvice) -> some View {
        Text(advice.text)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview {
    HStack(alignment: .top) {
        StreamEndedStatus(reason: .failed(""), advice: .consoleOffline, onRetry: {}, onEnd: {})

        StreamEndedStatus(reason: .userStopped, advice: nil, onRetry: {}, onEnd: {})
    }
}
#endif
