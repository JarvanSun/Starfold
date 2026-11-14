//
//  StreamView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import StreamKit
import SwiftUI

struct StreamView: View {
    @Environment(\.controlActiveState) private var activeState
    @Environment(\.dimensions) private var dimensions
    @State private var pictureInPicture: StreamPictureInPicture?
    @State private var isFullScreen = false

    let streamViewModel: StreamViewModel
    let settingsViewModel: SettingsViewModel

    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            StreamPicture(
                renderer: streamViewModel.renderer,
                isVisible: streamViewModel.hasFirstFrame,
                pictureInPicture: pictureInPicture
            )

            StreamKeyboardCapture(streamViewModel: streamViewModel)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

            FullScreenObserver(isFullScreen: $isFullScreen)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

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
                .ignoresSafeArea()
            }

            if streamViewModel.isShowingStatistics {
                StreamStatisticsView(readout: streamViewModel.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceLarge)
                    .allowsHitTesting(false)
            }

            if streamViewModel.isShowingControls {
                StreamControlBar(
                    settingsViewModel: settingsViewModel,
                    streamViewModel: streamViewModel,
                    pictureInPicture: pictureInPicture,
                    isFullScreen: isFullScreen,
                    onClose: onClose
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, dimensions.spaceXLarge)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: streamViewModel.isShowingControls)
        .onContinuousHover { movePointer($0) }
        .onChange(of: streamViewModel.areControlsRevealed) { _, areRevealed in
            hidePointer(whenControlsAreHidden: areRevealed)
        }
        .onChange(of: activeState) { _, state in releaseKeyboard(unlessKey: state) }
        .sheet(item: presentedDialog) {
            SystemDialogView(
                systemDialogsViewModel: streamViewModel.systemDialogsViewModel,
                dialog: $0
            )
        }
        .focusedSceneValue(\.activeStreamViewModel, streamViewModel)
        .focusedSceneValue(\.activePictureInPicture, pictureInPicture)
        .onAppear { preparePictureInPicture() }
        .navigationTitle(streamViewModel.target.name)
    }

    private func movePointer(_ phase: HoverPhase) {
        switch phase {
        case .active: streamViewModel.revealControls()
        case .ended: break
        }
    }

    private func hidePointer(whenControlsAreHidden areRevealed: Bool) {
        guard !areRevealed else { return }

        NSCursor.setHiddenUntilMouseMoves(true)
    }

    private func releaseKeyboard(unlessKey state: ControlActiveState) {
        guard state != .key else { return }

        streamViewModel.releaseKeyboard()
    }

    private func preparePictureInPicture() {
        guard let renderer = streamViewModel.renderer else { return }

        let pictureInPicture = StreamPictureInPicture(renderer: renderer, dimensions: dimensions)
        streamViewModel.onStop = { pictureInPicture.dismiss() }
        streamViewModel.onEnd = { pictureInPicture.stop() }
        self.pictureInPicture = pictureInPicture
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { streamViewModel.systemDialogsViewModel.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview("Game dialog") {
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

#Preview("Connecting") {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(
        streamViewModel: preview.streamViewModel,
        settingsViewModel: preview.settingsViewModel
    ) {}
    .frame(width: 1280, height: 720)
}
#endif
