//
//  PreviewObjectPoolStreams.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import CoreGraphics
import StarfoldShared
import StreamKit
import XboxKit

extension PreviewObjectPool {
    static func streamViewModel(
        phase: StreamPhase,
        dialogs: [SystemDialogRequest] = []
    ) -> StreamViewModel {
        let console = consoles[0]
        return streamViewModel(
            target: .console(id: console.id, name: console.name),
            backdrop: .console(type: console.consoleType),
            service: streamService(phase: phase, dialogs: dialogs),
            dependencies: streamDependencies
        )
    }

    static func cloudStreamViewModel(phase: StreamPhase) -> StreamViewModel {
        let game = cloudGames[1]
        return streamViewModel(
            target: .cloud(titleID: game.id, name: game.name),
            backdrop: .game(heroImage: game.product?.heroImage),
            service: streamService(phase: phase, dialogs: []),
            dependencies: streamDependencies
        )
    }

    static func streamPreview(
        phase: StreamPhase,
        dialogs: [SystemDialogRequest] = []
    ) -> StreamPreview {
        let console = consoles[0]
        return streamPreview(
            target: .console(id: console.id, name: console.name),
            backdrop: .console(type: console.consoleType),
            service: streamService(phase: phase, dialogs: dialogs)
        )
    }

    static func cloudStreamPreview(phase: StreamPhase) -> StreamPreview {
        let game = cloudGames[1]
        return streamPreview(
            target: .cloud(titleID: game.id, name: game.name),
            backdrop: .game(heroImage: game.product?.heroImage),
            service: streamService(phase: phase, dialogs: [])
        )
    }

    static var queuedPhase: StreamPhase {
        .queued(estimatedWait: .seconds(180))
    }

    static var hostNotRegisteredPhase: StreamPhase {
        .ended(.failed("WNSError: WaitingForServerToRegister"))
    }

    static var signInExpiredPhase: StreamPhase {
        .ended(.failed("Sign-in expired"))
    }

    static var streamStatistics: StreamStatistics {
        var statistics = StreamStatistics()
        statistics.resolution = CGSize(width: 1920, height: 1080)
        statistics.codec = "H.264"
        statistics.upscaledTo = CGSize(width: 3840, height: 2160)
        statistics.isToneMapped = true
        statistics.framesPerSecond = 60
        statistics.bitrateMbps = 18.4
        statistics.path = .local
        statistics.interface = "ethernet"
        statistics.roundTripMs = 6
        statistics.decodeMs = 3
        statistics.jitterBufferMs = 12
        statistics.displayMs = 9
        statistics.packetLossPercent = 0.1
        return statistics
    }

    static var systemDialogs: [SystemDialogRequest] {
        [messageDialog, keyboardDialog]
    }

    static var messageDialog: SystemDialogRequest {
        .init(
            id: "message",
            kind: .message(
                title: messageDialogTitle,
                text: messageDialogText,
                buttons: ["Save", "Don’t Save", "Cancel"],
                defaultIndex: 0,
                cancelIndex: 2
            )
        )
    }

    static var keyboardDialog: SystemDialogRequest {
        .init(
            id: "keyboard",
            kind: .keyboard(
                title: textPromptTitle,
                description: textPromptDescription,
                defaultText: textPromptText,
                maxLength: 16
            )
        )
    }

    static var messageDialogTitle: String {
        "Save your progress?"
    }

    static var messageDialogText: String {
        "Unsaved progress will be lost."
    }

    static var messageDialogButtons: [DialogButton] {
        streamViewModel(phase: .streaming).dialogs.buttons(of: messageDialog)
    }

    static var textPromptTitle: String {
        "Name"
    }

    static var textPromptDescription: String {
        "Name your squad."
    }

    static var textPromptText: String {
        "Nova Squad"
    }

    static var streamOverlays: StreamOverlays {
        .init(statisticsRows: statisticsRowKinds, controlsHideDelay: nil)
    }

    static var statisticsRowKinds: [StatisticsRowKind] {
        [
            .resolution,
            .codec,
            .upscaled,
            .dynamicRange,
            .lowered,
            .frameRate,
            .bitrate,
            .network,
            .roundTrip,
            .decode,
            .jitterBuffer,
            .display,
            .packetLoss,
        ]
    }

    static var statisticsReadout: StatisticsReadout {
        .init(
            statistics: streamStatistics,
            kinds: statisticsRowKinds,
            usesAutomaticQuality: true,
            loweredFrom: .high
        )
    }

    static func streamService(
        phase: StreamPhase,
        dialogs: [SystemDialogRequest]
    ) -> PreviewStreamService {
        .init(
            updates: [.phase(phase), .statistics(streamStatistics)] + dialogs.map { .dialog($0) }
        )
    }
}

private extension PreviewObjectPool {
    static func streamPreview(
        target: StreamTarget,
        backdrop: StreamBackdrop,
        service: PreviewStreamService
    ) -> StreamPreview {
        let preferences = Self.preferences
        let controllers = Self.controllers

        return .init(
            stream: streamViewModel(
                target: target,
                backdrop: backdrop,
                service: service,
                dependencies: streamDependencies(preferences: preferences, controllers: controllers)
            ),
            settings: settingsViewModel(preferences: preferences, controllers: controllers)
        )
    }

    static func streamViewModel(
        target: StreamTarget,
        backdrop: StreamBackdrop,
        service: PreviewStreamService,
        dependencies: StreamDependencies
    ) -> StreamViewModel {
        let stream = StreamViewModel(
            target: target,
            backdrop: backdrop,
            qualityOverride: nil,
            service: service,
            dependencies: dependencies
        )

        stream.start()

        return stream
    }
}
#endif
