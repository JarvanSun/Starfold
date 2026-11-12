//
//  StreamView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamView: View {
    @Environment(\.dimensions) private var dimensions

    let stream: StreamViewModel
    let settings: SettingsViewModel

    let onClose: () -> Void

    var body: some View {
        ZStack {
            StreamPicture(renderer: stream.renderer, isVisible: stream.hasFirstFrame)

            if stream.isWaitingForPicture {
                StreamStatusView(
                    name: stream.target.name,
                    status: stream.status,
                    backdrop: stream.backdrop,
                    onClose: onClose,
                    onTryAgain: { stream.tryAgain() }
                )
            }

            if stream.isShowingStatistics {
                StreamStatisticsView(readout: stream.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceXLarge)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .ornament(
            visibility: stream.isShowingControls ? .visible : .hidden,
            attachmentAnchor: .scene(.bottom),
            contentAlignment: .top
        ) {
            StreamControlBar(settings: settings, stream: stream, onDisconnect: onClose)
        }
        .sheet(item: presentedDialog) { SystemDialogView(dialogs: stream.dialogs, dialog: $0) }
    }
}

private extension StreamView {
    var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { stream.dialogs.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview("Streaming", windowStyle: .plain) {
    StreamView(
        stream: PreviewObjectPool.streamViewModel(phase: .streaming),
        settings: PreviewObjectPool.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}

#Preview("Connecting", windowStyle: .plain) {
    StreamView(
        stream: PreviewObjectPool.cloudStreamViewModel(phase: .connecting),
        settings: PreviewObjectPool.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}

#Preview("Game dialog", windowStyle: .plain) {
    StreamView(
        stream: PreviewObjectPool.streamViewModel(
            phase: .streaming,
            dialogs: [PreviewObjectPool.messageDialog]
        ),
        settings: PreviewObjectPool.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}
#endif
