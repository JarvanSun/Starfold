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

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { stream.dialogs.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview("Streaming", windowStyle: .plain) {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    StreamView(stream: preview.stream, settings: preview.settings) {}
        .frame(width: 1280, height: 720)
}

#Preview("Connecting", windowStyle: .plain) {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(stream: preview.stream, settings: preview.settings) {}
        .frame(width: 1280, height: 720)
}

#Preview("Game dialog", windowStyle: .plain) {
    let preview = PreviewObjectPool.streamPreview(
        phase: .streaming,
        dialogs: [PreviewObjectPool.messageDialog]
    )

    StreamView(stream: preview.stream, settings: preview.settings) {}
        .frame(width: 1280, height: 720)
}
#endif
