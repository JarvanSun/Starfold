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
    @State private var isEditingTouchLayout = false

    let streamViewModel: StreamViewModel
    let settingsViewModel: SettingsViewModel
    let controllers: ControllerHub

    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            StreamPicture(
                renderer: streamViewModel.renderer,
                isVisible: streamViewModel.hasFirstFrame
            )

            if streamViewModel.isWaitingForPicture {
                statusView
            }

            switch streamViewModel.touchControlsViewModel {
            case let touchControlsViewModel?: touchLayer(touchControlsViewModel)
            case nil: EmptyView()
            }

            if streamViewModel.isShowingStatistics {
                StreamStatisticsView(readout: streamViewModel.statisticsReadout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(dimensions.spaceLarge)
                    .allowsHitTesting(false)
            }

            if streamViewModel.isStreaming {
                menuLayer
            }
        }
        .contentShape(.rect)
        .onTapGesture { reveal() }
        .animation(.smooth(duration: 0.3), value: streamViewModel.isMenuOpen)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .defersSystemGestures(on: .all)
        .sensoryFeedback(trigger: streamViewModel.phase) { _, phase in phase.arrivalFeedback }
        .sensoryFeedback(.impact(weight: .light), trigger: controllers.connected.count)
        .sensoryFeedback(.impact(weight: .light), trigger: streamViewModel.isMenuOpen) {
            _,
            isOpen in
            isOpen
        }
        .landscapeOnPhone()
        .streamKeyboardInput(streamViewModel)
        .onAppear { streamViewModel.revealControls() }
        .onChange(of: streamViewModel.isRoutingInputToGame, initial: true) { _, isRouting in
            controllers.routeInput(toGame: isRouting)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            switch phase {
            case .active: streamViewModel.enterForeground()
            default: streamViewModel.enterBackground()
            }
        }
        .onDisappear { controllers.routeInput(toGame: false) }
        .touchLayoutEditorCover(
            isPresented: $isEditingTouchLayout,
            settingsViewModel: settingsViewModel
        )
        .sheet(item: presentedDialog) { dialog in
            SystemDialogView(
                systemDialogsViewModel: streamViewModel.systemDialogsViewModel,
                dialog: dialog
            )
            .interactiveDismissDisabled()
        }
    }

    private func touchLayer(_ touchControlsViewModel: TouchControlsViewModel) -> some View {
        TouchControlsLayer(
            touchControlsViewModel: touchControlsViewModel,
            isActive: streamViewModel.isShowingTouchControls,
            onConnect: { controllers.checkControllers() }
        )
    }

    private func reveal() {
        streamViewModel.revealControls()

        streamViewModel.touchControlsViewModel?.reveal()
    }

    private var statusView: some View {
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

    @ViewBuilder
    private var menuLayer: some View {
        switch (streamViewModel.isMenuOpen, streamViewModel.isShowingMenuHandle) {
        case (true, _): openMenu
        case (false, true): menuHandle
        case (false, false): EmptyView()
        }
    }

    private var openMenu: some View {
        ZStack(alignment: .top) {
            Color.clear
                .contentShape(.rect)
                .onTapGesture { streamViewModel.closeMenu() }

            StreamMenu(
                settingsViewModel: settingsViewModel,
                streamViewModel: streamViewModel,
                onEditTouchControls: { editTouchLayout() },
                onDisconnect: onClose
            )
            .padding(.top, dimensions.spaceSmall)
            .padding(.horizontal, dimensions.spaceLarge)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func editTouchLayout() {
        streamViewModel.closeMenu()
        settingsViewModel.editTouchLayout()
        isEditingTouchLayout = true
    }

    private var menuHandle: some View {
        StreamMenuHandle(isDimmed: !streamViewModel.areControlsRevealed) {
            streamViewModel.openMenu()
        }
        .padding(.top, dimensions.spaceXSmall)
        .frame(maxHeight: .infinity, alignment: .top)
        .transition(.opacity)
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
        settingsViewModel: preview.settingsViewModel,
        controllers: .init(routing: .direct)
    ) {}
}

#Preview("Connecting") {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .connecting)

    StreamView(
        streamViewModel: preview.streamViewModel,
        settingsViewModel: preview.settingsViewModel,
        controllers: .init(routing: .direct)
    ) {}
}
#endif
