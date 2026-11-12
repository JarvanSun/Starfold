//
//  StreamViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct StreamViewModelTests {
    let livingRoom: StreamTarget = .console(id: "X", name: "Living room")
    let dialog = SystemDialogRequest(
        id: "save",
        kind: .message(
            title: "Save?",
            text: "",
            buttons: ["Yes", "No"],
            defaultIndex: 0,
            cancelIndex: 1
        )
    )

    @Test
    func startThenShowsThePhasesTheConnectionReports() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.connecting), .phase(.streaming)]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.isStreaming })
        #expect(service.connectedTargets == [livingRoom])
    }

    @Test
    func startBeforeTheServiceAnswersThenIsProvisioning() {
        // Given
        let stream = makeStream(service: StreamServiceStub())

        // When
        stream.start()

        // Then
        #expect(stream.phase == .provisioning)
    }

    @Test
    func startWhenTheServiceFailsThenEndsWithItsMessage() async {
        // Given
        let service = StreamServiceStub()
        service.failure = URLError(.notConnectedToInternet)
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.hasEnded })
        #expect(
            stream.phase == .ended(.failed(URLError(.notConnectedToInternet).localizedDescription))
        )
    }

    @Test
    func startWhenSignInIsRequiredThenAsksForIt() async {
        // Given
        let service = StreamServiceStub()
        service.failure = XboxAccountError.signInRequired
        let stream = makeStream(service: service)
        var isSignInRequested = false
        stream.onSignInRequired = { isSignInRequested = true }

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { isSignInRequested })
        #expect(stream.hasEnded)
    }

    @Test
    func startWhenHostOpensADialogThenListsIt() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.streaming), .dialog(dialog)]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.dialogs.queue.map(\.id) == ["save"] })
    }

    @Test
    func startWhenHostDismissesADialogThenRemovesIt() async {
        // Given
        let notice = SystemDialogRequest(
            id: "notice",
            kind: .message(title: "Saved", text: "", buttons: [], defaultIndex: 0, cancelIndex: nil)
        )
        let service = StreamServiceStub()
        service.updates = [
            .phase(.streaming), .dialog(dialog), .dialog(notice), .dialogDismissed(id: "save"),
        ]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.dialogs.queue.map(\.id) == ["notice"] })
    }

    @Test(arguments: [SoundStage.direct, .window])
    func initThenSetsDirectStereoForTheChosenSoundStage(stage: SoundStage) {
        // Given
        let service = StreamServiceStub()
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.soundStage = stage

        // When
        makeStream(service: service, preferences: preferences)

        // Then
        #expect(service.directStereoChanges == [stage == .direct])
    }

    @Test
    func soundStageChangedDuringTheStreamThenIsApplied() async {
        // Given
        let service = StreamServiceStub()
        let preferences = Preferences(defaults: .dummyEmpty)
        let stream = makeStream(service: service, preferences: preferences)

        // When
        preferences.soundStage = .direct

        // Then
        #expect(await Eventually().holds { service.directStereoChanges == [false, true] })
        #expect(!stream.hasEnded)
    }

    @Test
    func settingChangedTwiceThenEachChangeIsApplied() async {
        // Given
        let service = StreamServiceStub()
        let preferences = Preferences(defaults: .dummyEmpty)
        let stream = makeStream(service: service, preferences: preferences)
        preferences.soundStage = .direct
        await Eventually().holds { service.directStereoChanges.count == 2 }

        // When
        preferences.soundStage = .window

        // Then
        #expect(await Eventually().holds { service.directStereoChanges == [false, true, false] })
        #expect(!stream.hasEnded)
    }

    @Test
    func statusWhileProvisioningThenIsConnecting() {
        #expect(makeStream(service: StreamServiceStub()).status == .connecting)
    }

    @Test
    func statusWhenQueuedBrieflyThenEstimatesAtLeastAMinute() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.queued(estimatedWait: .seconds(5)))]
        let stream = makeStream(service: service)
        let oneMinute = Duration.seconds(60).formatted(.units(allowed: [.minutes], width: .wide))

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.status == .queued(estimatedWait: oneMinute) })
    }

    @Test
    func statusWhenQueuedWithoutEstimateThenHasNoWait() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.queued(estimatedWait: nil))]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(await Eventually().holds { stream.status == .queued(estimatedWait: nil) })
    }

    @Test
    func statusWhenTheHostFailsThenCarriesItsAdvice() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.ended(.failed("WaitingForServerToRegister")))]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        let failed = StreamStatus.ended(
            .failed("WaitingForServerToRegister"),
            advice: .consoleOffline
        )
        #expect(await Eventually().holds { stream.status == failed })
    }

    @Test
    func statusAfterThePlayerStopsThenHasNoAdvice() async {
        // Given
        let stream = makeStream(service: StreamServiceStub())

        // When
        await stream.stop()

        // Then
        #expect(stream.status == .ended(.userStopped, advice: nil))
    }

    @Test
    func streamingBeforeTheFirstFrameThenIsStillWaitingForPicture() async {
        // Given
        let stream = await makeStreamingStream()

        // Then
        #expect(stream.isWaitingForPicture)
    }

    @Test
    func streamingThenShowsControlsAndHidesThemAfterTheDelay() async {
        // Given
        let stream = await makeStreamingStream()
        let wereControlsShown = stream.isShowingControls

        // Then
        #expect(wereControlsShown)
        #expect(await Eventually().holds { !stream.isShowingControls })
    }

    @Test
    func revealControlsAfterTheyHidThenShowsThemAgain() async {
        // Given
        let stream = await makeStreamingStream()
        await Eventually().holds { !stream.isShowingControls }

        // When
        stream.revealControls()

        // Then
        #expect(stream.isShowingControls)
    }

    @Test
    func revealControlsBeforeStreamingThenShowsNoControls() {
        // Given
        let stream = makeStream(service: StreamServiceStub())

        // When
        stream.revealControls()

        // Then
        #expect(!stream.isShowingControls)
    }

    @Test(arguments: [true, false])
    func isShowingStatisticsWhileStreamingThenFollowsThePreference(isChosen: Bool) async {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.shouldShowStatistics = isChosen

        // When
        let stream = await makeStreamingStream(preferences: preferences)

        // Then
        #expect(stream.isShowingStatistics == isChosen)
    }

    @Test
    func isShowingStatisticsBeforeStreamingThenIsFalse() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.shouldShowStatistics = true

        // When
        let stream = makeStream(service: StreamServiceStub(), preferences: preferences)

        // Then
        #expect(!stream.isShowingStatistics)
    }

    @Test
    func statisticsReadoutThenShowsThePlatformsRowsThatHaveValues() async {
        // Given
        var statistics = StreamStatistics()
        statistics.resolution = CGSize(width: 1920, height: 1080)
        statistics.framesPerSecond = 60
        statistics.bitrateMbps = 18
        let service = StreamServiceStub()
        service.updates = [.phase(.streaming), .statistics(statistics)]
        let stream = makeStream(service: service)

        // When
        stream.start()

        // Then
        #expect(
            await Eventually().holds {
                stream.statisticsReadout.rows.map(\.kind) == [.resolution, .frameRate]
            }
        )
    }

    @Test
    func canOpenMenuWhileADialogIsOpenThenIsFalse() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.streaming), .dialog(dialog)]
        let stream = makeStream(service: service)
        stream.start()
        await Eventually().holds { stream.dialogs.presentedDialog != nil }

        // Then
        #expect(!stream.canOpenMenu)
    }

    @Test
    func canOpenMenuWhileStreamingThenIsTrue() async {
        // Given
        let stream = await makeStreamingStream()

        // Then
        #expect(stream.canOpenMenu)
    }

    @Test
    func tryAgainTwiceThenAsksForOneRestart() async {
        // Given
        let stream = makeStream(service: StreamServiceStub())
        var restartCount = 0
        stream.onRestart = { restartCount += 1 }

        // When
        stream.tryAgain()
        stream.tryAgain()

        // Then
        #expect(await Eventually().holds { restartCount == 1 })
        try? await Task.sleep(for: .milliseconds(30))
        #expect(restartCount == 1)
    }

    @Test
    func showNextPictureFitThenCyclesThroughEveryFit() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let stream = makeStream(service: StreamServiceStub(), preferences: preferences)

        // When
        var shownFits: [PictureFit] = []
        for _ in PictureFit.allCases {
            stream.showNextPictureFit()

            shownFits.append(preferences.pictureFit)
        }

        // Then
        #expect(shownFits == [.fill, .scale, .fit])
    }

    @Test(arguments: [(0.0, SharpeningLevel.off), (0.3, .low), (0.5, .medium), (0.95, .high)])
    func sharpeningLevelThenIsTheLevelNearestTheSavedStrength(
        strength: Double,
        level: SharpeningLevel
    ) {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.sharpening = strength

        // When
        let stream = makeStream(service: StreamServiceStub(), preferences: preferences)

        // Then
        #expect(stream.sharpeningLevel == level)
    }

    @Test
    func sharpeningLevelWhenChosenThenSavesItsStrength() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        let stream = makeStream(service: StreamServiceStub(), preferences: preferences)

        // When
        stream.sharpeningLevel = .high

        // Then
        #expect(preferences.sharpening == 1)
    }

    @Test
    func stopThenEndsAsStoppedByThePlayer() async {
        // Given
        let service = StreamServiceStub()
        service.updates = [.phase(.streaming)]
        let stream = makeStream(service: service)
        stream.start()
        await Eventually().holds { stream.isStreaming }

        // When
        await stream.stop()

        // Then
        #expect(stream.phase == .ended(.userStopped))
    }
}

private extension StreamViewModelTests {
    func makeStreamingStream(
        preferences: Preferences = .init(defaults: .dummyEmpty)
    ) async -> StreamViewModel {
        let service = StreamServiceStub()
        service.updates = [.phase(.streaming)]
        let stream = makeStream(service: service, preferences: preferences)

        stream.start()
        await Eventually().holds { stream.isStreaming }

        return stream
    }

    @discardableResult
    func makeStream(
        service: StreamServiceStub,
        preferences: Preferences = .init(defaults: .dummyEmpty)
    ) -> StreamViewModel {
        .init(
            target: livingRoom,
            backdrop: .console(type: "XboxSeriesX"),
            qualityOverride: nil,
            service: service,
            dependencies: .dummy(preferences: preferences)
        )
    }
}
