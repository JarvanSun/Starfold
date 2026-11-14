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

    let streamViewModel: StreamViewModel
    let settingsViewModel: SettingsViewModel

    let onClose: () -> Void

    var body: some View {
        ZStack {
            StreamPicture(
                renderer: streamViewModel.renderer,
                isVisible: streamViewModel.hasFirstFrame
            )

            if streamViewModel.isWaitingForPicture {
                StreamStatusView(
                    name: streamViewModel.target.name,
                    status: streamViewModel.status,
                    backdrop: streamViewModel.backdrop,
                    isXboxButtonTakenBySystem: streamViewModel.isXboxButtonTakenBySystem,
                    onClose: onClose,
                    onTryAgain: { streamViewModel.tryAgain() },
                    onOpenXboxButtonSettings: { streamViewModel.openXboxButtonSettings() }
                )
            }

            if streamViewModel.isShowingStatistics {
                StreamStatisticsView(readout: streamViewModel.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceXLarge)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXXLarge))
        .ornament(
            visibility: streamViewModel.isShowingControls ? .visible : .hidden,
            attachmentAnchor: .scene(.bottom),
            contentAlignment: .top
        ) {
            StreamControlBar(
                settingsViewModel: settingsViewModel,
                streamViewModel: streamViewModel,
                onDisconnect: onClose
            )
        }
        .sheet(item: presentedDialog) {
            SystemDialogView(
                systemDialogsViewModel: streamViewModel.systemDialogsViewModel,
                dialog: $0
            )
        }
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { streamViewModel.systemDialogsViewModel.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview("Streaming", windowStyle: .plain) {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    StreamView(
        streamViewModel: preview.streamViewModel,
        settingsViewModel: preview.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}

#Preview("Connecting", windowStyle: .plain) {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(
        streamViewModel: preview.streamViewModel,
        settingsViewModel: preview.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}

#Preview("Game dialog", windowStyle: .plain) {
    let preview = PreviewObjectPool.streamPreview(
        phase: .streaming,
        dialogs: [PreviewObjectPool.messageDialog]
    )

    StreamView(
        streamViewModel: preview.streamViewModel,
        settingsViewModel: preview.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}
#endif
