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

    let stream: StreamViewModel
    let settings: SettingsViewModel

    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            StreamPicture(
                renderer: stream.renderer,
                isVisible: stream.hasFirstFrame,
                pictureInPicture: pictureInPicture
            )

            StreamKeyboardCapture(stream: stream)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

            FullScreenObserver(isFullScreen: $isFullScreen)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

            if stream.isWaitingForPicture {
                StreamStatusView(
                    name: stream.target.name,
                    status: stream.status,
                    backdrop: stream.backdrop,
                    isXboxButtonTakenBySystem: stream.isXboxButtonTakenBySystem,
                    onClose: onClose,
                    onTryAgain: { stream.tryAgain() },
                    onOpenXboxButtonSettings: { stream.openXboxButtonSettings() }
                )
                .ignoresSafeArea()
            }

            if stream.isShowingStatistics {
                StreamStatisticsView(readout: stream.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceLarge)
                    .allowsHitTesting(false)
            }

            if stream.isShowingControls {
                StreamControlBar(
                    settings: settings,
                    stream: stream,
                    pictureInPicture: pictureInPicture,
                    isFullScreen: isFullScreen,
                    onClose: onClose
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, dimensions.spaceXLarge)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: stream.isShowingControls)
        .onContinuousHover { movePointer($0) }
        .onChange(of: stream.areControlsRevealed) { _, areRevealed in
            hidePointer(whenControlsAreHidden: areRevealed)
        }
        .onChange(of: activeState) { _, state in releaseKeyboard(unlessKey: state) }
        .sheet(item: presentedDialog) { SystemDialogView(dialogs: stream.dialogs, dialog: $0) }
        .focusedSceneValue(\.activeStream, stream)
        .focusedSceneValue(\.activePictureInPicture, pictureInPicture)
        .onAppear { preparePictureInPicture() }
        .navigationTitle(stream.target.name)
    }

    private func movePointer(_ phase: HoverPhase) {
        switch phase {
        case .active: stream.revealControls()
        case .ended: break
        }
    }

    private func hidePointer(whenControlsAreHidden areRevealed: Bool) {
        guard !areRevealed else { return }

        NSCursor.setHiddenUntilMouseMoves(true)
    }

    private func releaseKeyboard(unlessKey state: ControlActiveState) {
        guard state != .key else { return }

        stream.releaseKeyboard()
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { stream.dialogs.presentedDialog }, set: { _ in })
    }

    private func preparePictureInPicture() {
        guard let renderer = stream.renderer else { return }

        let pictureInPicture = StreamPictureInPicture(renderer: renderer, dimensions: dimensions)
        stream.onStop = { pictureInPicture.dismiss() }
        stream.onEnd = { pictureInPicture.stop() }
        self.pictureInPicture = pictureInPicture
    }
}

#if DEBUG
#Preview("Game dialog") {
    let preview = PreviewObjectPool.streamPreview(
        phase: .streaming,
        dialogs: [PreviewObjectPool.messageDialog]
    )

    StreamView(stream: preview.stream, settings: preview.settings) {}
        .frame(width: 1280, height: 720)
}

#Preview("Connecting") {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(stream: preview.stream, settings: preview.settings) {}
        .frame(width: 1280, height: 720)
}
#endif
