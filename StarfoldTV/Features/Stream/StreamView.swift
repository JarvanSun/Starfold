//
//  StreamView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/30.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamView: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var streamPresenter: StreamPresenter

    let streamViewModel: StreamViewModel?
    let settingsViewModel: SettingsViewModel
    let controllerHub: ControllerHub

    var body: some View {
        StreamHost(
            isRawInputEnabled: streamPresenter.isRawInputEnabled(for: streamViewModel),
            onRemoteBack: { goBack() },
            onRemotePlayPause: { openMenu() }
        ) {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                switch streamViewModel {
                case let streamViewModel?: layers(of: streamViewModel)
                case nil: StreamPreparingStatus()
                }

                if streamPresenter.isEnding {
                    StreamDisconnectingStatus()
                }
            }
            .environment(\.colorScheme, .dark)
            .onExitCommand { goBack() }
            .onPlayPauseCommand { openMenu() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onChange(of: streamPresenter.isRawInputEnabled(for: streamViewModel), initial: true) {
            _,
            isEnabled in
            controllerHub.routeInput(toGame: isEnabled)
        }
        .onDisappear { controllerHub.routeInput(toGame: false) }
        .sheet(isPresented: $streamPresenter.isMenuPresented) { menu }
        .sheet(item: presentedDialog) { dialog in dialogSheet(dialog) }
    }

    private func goBack() {
        Task { await streamPresenter.goBack() }
    }

    private func openMenu() {
        streamPresenter.openMenu(for: streamViewModel)
    }

    @ViewBuilder
    private func layers(of streamViewModel: StreamViewModel) -> some View {
        StreamPicture(renderer: streamViewModel.renderer, isVisible: streamViewModel.hasFirstFrame)

        if streamViewModel.isWaitingForPicture {
            StreamStatusView(
                name: streamViewModel.target.name,
                status: streamViewModel.status,
                onRetry: { restart() },
                onEnd: { end() }
            )
        }

        if streamViewModel.isShowingStatistics {
            StreamStatisticsView(readout: streamViewModel.statisticsReadout)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(dimensions.spaceHuge)
                .allowsHitTesting(false)
        }

        if streamViewModel.needsController {
            ControllerMissingStatus(onCheckAgain: { controllerHub.checkControllers() })
        }
    }

    private func restart() {
        Task { await streamPresenter.restart() }
    }

    private func end() {
        Task { await streamPresenter.end() }
    }

    @ViewBuilder
    private func dialogSheet(_ dialog: SystemDialogRequest) -> some View {
        switch streamViewModel {
        case let streamViewModel?:
            SystemDialogView(
                systemDialogsViewModel: streamViewModel.systemDialogsViewModel,
                dialog: dialog
            )
            .interactiveDismissDisabled()
        case nil: EmptyView()
        }
    }

    @ViewBuilder
    private var menu: some View {
        switch streamViewModel {
        case let streamViewModel?:
            StreamMenuView(
                settingsViewModel: settingsViewModel,
                streamViewModel: streamViewModel,
                onDisconnect: { end() }
            )
        case nil: EmptyView()
        }
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { streamViewModel?.systemDialogsViewModel.presentedDialog }, set: { _ in })
    }
}

#if DEBUG
#Preview(
    "Stream",
    arguments: [
        StreamPhase.provisioning,
        PreviewObjectPool.queuedPhase,
        PreviewObjectPool.hostNotRegisteredPhase,
        .ended(.connectionLost),
        .streaming,
    ]
) { phase in
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    StreamView(
        streamPresenter: StreamPresenter(appViewModel: app),
        streamViewModel: PreviewObjectPool.streamViewModel(phase: phase),
        settingsViewModel: app.settingsViewModel,
        controllerHub: app.controllerHub
    )
}

#Preview("Preparing") {
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    StreamView(
        streamPresenter: StreamPresenter(appViewModel: app),
        streamViewModel: nil,
        settingsViewModel: app.settingsViewModel,
        controllerHub: app.controllerHub
    )
}
#endif
