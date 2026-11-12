//
//  StreamStatusView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI
import XboxKit

struct StreamStatusView: View {
    @Environment(\.dimensions) private var dimensions

    let name: String
    let status: StreamStatus
    let onRetry: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text(name)
                .font(.title.bold())

            switch status {
            case .connecting, .queued: StreamProgressStatus(title: status.title, onCancel: onEnd)
            case .ended(let reason, let advice):
                StreamEndedStatus(reason: reason, advice: advice, onRetry: onRetry, onEnd: onEnd)
            }
        }
        .padding(dimensions.spaceHuge)
        .frame(maxWidth: dimensions.streamStatusMaximumWidth)
    }
}

#if DEBUG
#Preview {
    let statuses: [StreamStatus] = [
        .connecting,
        .queued(estimatedWait: nil),
        .ended(.failed(""), advice: .consoleOffline),
        .ended(.connectionLost, advice: .networkDropped),
    ]
    HStack(alignment: .top) {
        ForEach(Array(statuses.enumerated()), id: \.offset) { _, status in
            StreamStatusView(
                name: PreviewObjectPool.consoles[0].name,
                status: status,
                onRetry: {},
                onEnd: {}
            )
        }
    }
}
#endif
