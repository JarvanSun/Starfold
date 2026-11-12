//
//  StreamStatusView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamStatusView: View {
    @Environment(\.dimensions) private var dimensions

    let name: String
    let status: StreamStatus
    let backdrop: StreamBackdrop
    let onClose: () -> Void
    let onTryAgain: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Text(name)
                .font(.extraLargeTitle2)
                .multilineTextAlignment(.center)

            switch status {
            case .connecting, .queued: StreamProgressStatus(title: status.title, onCancel: onClose)
            case .ended(let reason, let advice):
                StreamEndedStatus(
                    reason: reason,
                    advice: advice,
                    onClose: onClose,
                    onTryAgain: onTryAgain
                )
            }
        }
        .padding(dimensions.spaceXXXLarge)
        .frame(maxWidth: dimensions.readableTextMaximumWidth)
        .animation(.smooth(duration: 0.4), value: status)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { StreamBackdropView(backdrop: backdrop) }
        .clipped()
        .glassBackgroundEffect()
    }
}

#if DEBUG
#Preview("Connecting", windowStyle: .plain) {
    let stream = PreviewObjectPool.streamViewModel(phase: .connecting)
    StreamStatusView(
        name: stream.target.name,
        status: .connecting,
        backdrop: stream.backdrop,
        onClose: {},
        onTryAgain: {}
    )
    .frame(width: 1280, height: 720)
}

#Preview("In line", windowStyle: .plain) {
    let stream = PreviewObjectPool.cloudStreamViewModel(phase: PreviewObjectPool.queuedPhase)
    StreamStatusView(
        name: stream.target.name,
        status: .queued(estimatedWait: nil),
        backdrop: stream.backdrop,
        onClose: {},
        onTryAgain: {}
    )
    .frame(width: 1280, height: 720)
}

#Preview("Failed", windowStyle: .plain) {
    let stream = PreviewObjectPool.streamViewModel(phase: .connecting)
    StreamStatusView(
        name: stream.target.name,
        status: .ended(.failed(""), advice: .consoleOffline),
        backdrop: stream.backdrop,
        onClose: {},
        onTryAgain: {}
    )
    .frame(width: 1280, height: 720)
}

#Preview("Ended", windowStyle: .plain) {
    let stream = PreviewObjectPool.streamViewModel(phase: .connecting)
    StreamStatusView(
        name: stream.target.name,
        status: .ended(.userStopped, advice: nil),
        backdrop: stream.backdrop,
        onClose: {},
        onTryAgain: {}
    )
    .frame(width: 1280, height: 720)
}
#endif
