//
//  StreamStatusView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
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
                .font(.system(size: dimensions.streamTitleSize, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.6), radius: dimensions.shadowRadiusMedium)

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
        .padding(dimensions.spaceXXLarge)
        .frame(maxWidth: dimensions.streamStatusWidth)
        .animation(.smooth(duration: 0.4), value: status)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { StreamBackdropView(backdrop: backdrop) }
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
    }
}

#if DEBUG
@available(macOS 27, *)
#Preview(
    "Stream status",
    arguments: [
        PreviewObjectPool.streamViewModel(phase: .connecting),
        PreviewObjectPool.cloudStreamViewModel(phase: PreviewObjectPool.queuedPhase),
        PreviewObjectPool.streamViewModel(phase: PreviewObjectPool.hostNotRegisteredPhase),
    ]
) { stream in
    StreamStatusView(
        name: stream.target.name,
        status: stream.status,
        backdrop: stream.backdrop,
        onClose: {},
        onTryAgain: {}
    )
    .frame(width: 1280, height: 720)
}
#endif
