//
//  StreamView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dimensions) private var dimensions

    let stream: StreamViewModel
    let settings: SettingsViewModel
    let controllers: ControllerHub

    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            StreamPicture(renderer: stream.renderer, isVisible: stream.hasFirstFrame)

            if stream.isWaitingForPicture {
                statusView
            }

            if stream.isShowingStatistics {
                StreamStatisticsView(readout: stream.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceLarge)
                    .allowsHitTesting(false)
            }

            if stream.isStreaming {
                menuLayer
            }
        }
        .contentShape(.rect)
        .onTapGesture { stream.revealControls() }
        .animation(.smooth(duration: 0.3), value: stream.isMenuOpen)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .all)
        .landscapeOnPhone()
        .streamKeyboardInput(stream)
        .onAppear { stream.revealControls() }
        .onChange(of: stream.isRoutingInputToGame, initial: true) { _, isRouting in
            controllers.routeInput(toGame: isRouting)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            stream.moveToForeground(phase == .active)

            if phase != .active { stream.releaseKeyboard() }
        }
        .onDisappear { controllers.routeInput(toGame: false) }
        .sheet(item: presentedDialog) { dialog in
            SystemDialogView(dialogs: stream.dialogs, dialog: dialog)
                .interactiveDismissDisabled()
        }
    }

    private var statusView: some View {
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

    @ViewBuilder
    private var menuLayer: some View {
        switch stream.isMenuOpen {
        case true: openMenu
        case false: menuHandle
        }
    }

    private var openMenu: some View {
        ZStack(alignment: .top) {
            Color.clear
                .contentShape(.rect)
                .onTapGesture { stream.closeMenu() }

            StreamMenu(
                settings: settings,
                stream: stream,
                onEditTouchControls: { stream.closeMenu() },
                onDisconnect: onClose
            )
            .padding(.top, dimensions.spaceSmall)
            .padding(.horizontal, dimensions.spaceLarge)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private var menuHandle: some View {
        StreamMenuHandle(isDimmed: !stream.areControlsRevealed) { stream.openMenu() }
            .padding(.top, dimensions.spaceXSmall)
            .frame(maxHeight: .infinity, alignment: .top)
            .transition(.opacity)
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { stream.dialogs.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview("Game dialog") {
    let preview = PreviewObjectPool.streamPreview(
        phase: .streaming,
        dialogs: [PreviewObjectPool.messageDialog]
    )

    StreamView(
        stream: preview.stream,
        settings: preview.settings,
        controllers: .init(routing: .direct)
    ) {}
}

#Preview("Connecting") {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(
        stream: preview.stream,
        settings: preview.settings,
        controllers: .init(routing: .direct)
    ) {}
}
#endif
