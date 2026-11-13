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
    @Bindable var presenter: StreamPresenter

    let stream: StreamViewModel?
    let settings: SettingsViewModel
    let controllers: ControllerHub

    var body: some View {
        StreamHost(
            isRawInputEnabled: presenter.isRawInputEnabled(for: stream),
            onRemoteBack: { goBack() },
            onRemotePlayPause: { openMenu() }
        ) {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                switch stream {
                case let stream?: layers(of: stream)
                case nil: StreamPreparingStatus()
                }

                if presenter.isEnding {
                    StreamDisconnectingStatus()
                }
            }
            .environment(\.colorScheme, .dark)
            .onExitCommand { goBack() }
            .onPlayPauseCommand { openMenu() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onChange(of: presenter.isRawInputEnabled(for: stream), initial: true) { _, isEnabled in
            controllers.routeInput(toGame: isEnabled)
        }
        .onDisappear { controllers.routeInput(toGame: false) }
        .sheet(isPresented: $presenter.isMenuPresented) { menu }
        .sheet(item: presentedDialog) { dialog in dialogSheet(dialog) }
    }

    private func goBack() {
        Task { await presenter.goBack() }
    }

    private func openMenu() {
        presenter.openMenu(for: stream)
    }

    @ViewBuilder
    private func layers(of stream: StreamViewModel) -> some View {
        StreamPicture(renderer: stream.renderer, isVisible: stream.hasFirstFrame)

        if stream.isWaitingForPicture {
            StreamStatusView(
                name: stream.target.name,
                status: stream.status,
                onRetry: { restart() },
                onEnd: { end() }
            )
        }

        if stream.isShowingStatistics {
            StreamStatisticsView(readout: stream.statisticsReadout)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(dimensions.spaceHuge)
                .allowsHitTesting(false)
        }

        if stream.needsController {
            ControllerMissingStatus(onCheckAgain: { controllers.checkControllers() })
        }
    }

    private func restart() {
        Task { await presenter.restart() }
    }

    private func end() {
        Task { await presenter.end() }
    }

    @ViewBuilder
    private var menu: some View {
        switch stream {
        case let stream?:
            StreamMenuView(settings: settings, stream: stream, onDisconnect: { end() })
        case nil: EmptyView()
        }
    }

    private var presentedDialog: Binding<SystemDialogRequest?> {
        .init(get: { stream?.dialogs.presentedDialog }, set: { _ in })
    }

    @ViewBuilder
    private func dialogSheet(_ dialog: SystemDialogRequest) -> some View {
        switch stream {
        case let stream?:
            SystemDialogView(dialogs: stream.dialogs, dialog: dialog)
                .interactiveDismissDisabled()
        case nil: EmptyView()
        }
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
        presenter: StreamPresenter(app: app),
        stream: PreviewObjectPool.streamViewModel(phase: phase),
        settings: app.settings,
        controllers: app.controllers
    )
}

#Preview("Preparing") {
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    StreamView(
        presenter: StreamPresenter(app: app),
        stream: nil,
        settings: app.settings,
        controllers: app.controllers
    )
}
#endif
