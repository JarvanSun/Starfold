//
//  HomeViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics
import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct HomeViewModelTests {
    @Test
    func refreshConsolesThenListsThemByNameWithTheirState() async {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .success([.dummyLivingRoom(powerState: .on), .dummyBedroom])

        // When
        await home.refreshConsoles()

        // Then
        #expect(home.consolesState == .loaded)
        #expect(home.consoles.map(\.name) == ["Bedroom", "Living room"])
        #expect(home.consoles.first?.hasWirelessWarning == true)
    }

    @Test
    func refreshConsolesWhenServiceFailsThenStateIsFailed() async {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .failure(URLError(.notConnectedToInternet))

        // When
        await home.refreshConsoles()

        // Then
        #expect(isFailed(home.consolesState), "\(home.consolesState)")
    }

    @Test
    func refreshConsolesWhenSignInIsRequiredThenAsksForIt() async {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .failure(XboxAccountError.signInRequired)
        var isSignInRequested = false
        home.onSignInRequired = { isSignInRequested = true }

        // When
        await home.refreshConsoles()

        // Then
        #expect(isSignInRequested)
    }

    @Test
    func initWhenRelaunchedWithoutNetworkThenShowsSavedConsoles() async {
        // Given
        let (harness, service, home) = makeHome()
        service.listed = .success([.dummyLivingRoom(powerState: .on)])

        await home.refresh()

        let relaunch = AppHarness(relaunching: harness)
        let offline = ConsoleServiceStub()
        offline.isHanging = true

        // When
        let cached = relaunch.home(for: "2535", service: offline)

        // Then
        #expect(cached.consoles.map(\.name) == ["Living room"])
        #expect(cached.consolesState == .loaded)
    }

    @Test
    func initWhenAnotherAccountSavedConsolesThenStartsEmpty() async {
        // Given
        let (harness, service, home) = makeHome()
        service.listed = .success([.dummyLivingRoom(powerState: .on)])

        await home.refresh()

        // When
        let otherHome = harness.home(for: "9999", service: ConsoleServiceStub())

        // Then
        #expect(otherHome.consoles.isEmpty)
        #expect(otherHome.consolesState == .idle)
    }

    @Test
    func activityWhenConsoleFallsAsleepThenKeepsLastGameSeenOnIt() async throws {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .success([.dummyLivingRoom(powerState: .on)])
        service.playing = .success(.dummyDiablo)

        await home.refresh()

        let playing = try #require(home.consoles.first)
        let activityWhilePlaying = home.activity(for: playing)
        service.listed = .success([.dummyLivingRoom(powerState: .connectedStandby)])
        service.playing = .success(nil)

        // When
        await home.refresh()

        // Then
        let sleeping = try #require(home.consoles.first)
        #expect(activityWhilePlaying?.kind == .playingNow)
        #expect(activityWhilePlaying?.name == "Diablo IV")
        #expect(home.activity(for: sleeping)?.kind == .lastPlayedHere)
        #expect(home.activity(for: sleeping)?.name == "Diablo IV")
    }

    @Test
    func activityWhenConsoleWasNeverSeenPlayingThenIsNilEvenIfPlayedElsewhere() async throws {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .success([.dummyLivingRoom(powerState: .connectedStandby)])
        service.playing = .success(.dummyDiablo)

        await home.refreshConsoles()

        // When
        await home.refreshConsoleActivity()

        // Then
        let console = try #require(home.consoles.first)
        #expect(home.activity(for: console) == nil)
    }

    @Test
    func keepConsolesFreshWhenConsoleTurnsOnElsewhereThenShowsItOn() async {
        // Given
        let clock = ClockStub()
        let (_, service, home) = makeHome(clock: clock)
        service.listed = .success([.dummyLivingRoom(powerState: .connectedStandby)])

        await home.refreshConsoles()

        service.listed = .success([.dummyLivingRoom(powerState: .on)])
        let refreshing = Task { await home.keepConsolesFresh() }
        defer { refreshing.cancel() }

        _ = await Eventually().holds { clock.sleeperCount == 1 }

        // When
        clock.advance(by: .seconds(30))

        // Then
        #expect(await Eventually().holds { home.consoles.first?.powerState == .on })
    }

    @Test
    func keepConsolesFreshWhenListWasJustReadThenReadsAgainOnlyAfterInterval() async {
        // Given
        let clock = ClockStub()
        let (_, service, home) = makeHome(clock: clock)

        await home.refreshConsoles()

        let reads = service.consoleReads
        let refreshing = Task {
            await home.keepConsolesFresh(every: .seconds(60), refreshingIfOlderThan: .seconds(10))
        }
        defer { refreshing.cancel() }

        _ = await Eventually().holds { clock.sleeperCount == 1 }

        // When
        clock.advance(by: .seconds(59))

        _ = await Eventually().holds { clock.sleeperCount == 1 }

        let readsBeforeInterval = service.consoleReads

        clock.advance(by: .seconds(1))

        // Then
        #expect(readsBeforeInterval == reads)
        #expect(await Eventually().holds { service.consoleReads == reads + 1 })
    }

    @Test
    func keepConsolesFreshWhenListIsOlderThanThresholdThenReadsAtOnce() async {
        // Given
        let clock = ClockStub()
        let (_, service, home) = makeHome(clock: clock)

        await home.refreshConsoles()

        let reads = service.consoleReads

        clock.advance(by: .seconds(11))

        // When
        let refreshing = Task {
            await home.keepConsolesFresh(every: .seconds(60), refreshingIfOlderThan: .seconds(10))
        }
        defer { refreshing.cancel() }

        // Then
        #expect(await Eventually().holds { service.consoleReads == reads + 1 })
    }

    @Test
    func sendWhenConsoleAcceptsCommandThenFinishesWithoutPollingConsoles() async {
        // Given
        let (_, service, home) = makeHome()
        let console = Console.dummyLivingRoom(powerState: .on)
        let reads = service.consoleReads

        // When
        await home.send(.turnOff, to: console)

        // Then
        #expect(home.powerProblem == nil)
        #expect(home.pendingPowerCommands.isEmpty)
        #expect(service.consoleReads == reads)
    }

    @Test
    func sendWhenCommandFailsThenReportsProblem() async {
        // Given
        let (_, service, home) = makeHome()
        service.commandResult = .failure(URLError(.badServerResponse))

        // When
        await home.send(.turnOff, to: .dummyLivingRoom(powerState: .on))

        // Then
        #expect(home.powerProblem?.consoleName == "Living room")
        #expect(home.pendingPowerCommands.isEmpty)
    }

    @Test
    func consolesContentWhenNothingIsLoadedYetThenIsLoading() {
        // Given / When
        let (_, _, home) = makeHome()

        // Then
        #expect(home.consolesContent == .loading)
    }

    @Test
    func consolesContentWhenFirstLoadFailsThenIsFailed() async {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .failure(URLError(.notConnectedToInternet))

        // When
        await home.refreshConsoles()

        // Then
        #expect(
            home.consolesContent == .failed(URLError(.notConnectedToInternet).localizedDescription)
        )
    }

    @Test
    func consolesContentWhenAccountHasNoConsolesThenIsEmpty() async {
        // Given
        let (_, _, home) = makeHome()

        // When
        await home.refreshConsoles()

        // Then
        #expect(home.consolesContent == .empty)
    }

    @Test
    func consolesContentWhenRefreshFailsWithConsolesOnScreenThenStaysConsoles() async {
        // Given
        let (_, service, home) = makeHome()
        service.listed = .success([.dummyBedroom])

        await home.refreshConsoles()

        service.listed = .failure(URLError(.notConnectedToInternet))

        // When
        await home.refreshConsoles()

        // Then
        #expect(home.consolesContent == .consoles)
    }

    @Test(
        arguments: [
            (Console.PowerState.on, ConsolePowerControl.command(.turnOff)),
            (.connectedStandby, .command(.wakeUp)),
            (.off, .unavailable),
            (.unknown, .unavailable),
        ]
    )
    func powerControlThenOffersTheCommandThePowerStateAllows(
        powerState: Console.PowerState,
        expected: ConsolePowerControl
    ) {
        // Given / When
        let (_, _, home) = makeHome()

        // Then
        #expect(home.powerControl(for: .dummyLivingRoom(powerState: powerState)) == expected)
    }

    @Test
    func powerControlWhileCommandIsOnItsWayThenIsSending() async {
        // Given
        let (_, service, home) = makeHome()
        let console = Console.dummyLivingRoom(powerState: .on)
        service.isCommandHanging = true

        // When
        let sending = Task { await home.togglePower(of: console) }
        defer { sending.cancel() }

        // Then
        #expect(await Eventually().holds { home.powerControl(for: console) == .sending(.turnOff) })
    }

    @Test(
        arguments: [
            (Console.PowerState.on, [XboxLiveClient.PowerCommand.turnOff]),
            (.connectedStandby, [.wakeUp]),
            (.off, []),
        ]
    )
    func togglePowerThenSendsTheCommandThePowerStateAllows(
        powerState: Console.PowerState,
        expected: [XboxLiveClient.PowerCommand]
    ) async {
        // Given
        let (_, service, home) = makeHome()

        // When
        await home.togglePower(of: .dummyLivingRoom(powerState: powerState))

        // Then
        #expect(service.sentCommands == expected)
    }

    @Test(
        arguments: [
            (Console.PowerState.on, ConsoleStatus.on),
            (.connectedStandby, .standby),
            (.off, .unreachable),
        ]
    )
    func statusThenFollowsThePowerState(powerState: Console.PowerState, expected: ConsoleStatus) {
        // Given / When
        let (_, _, home) = makeHome()

        // Then
        #expect(home.status(of: .dummyLivingRoom(powerState: powerState)) == expected)
    }

    @Test
    func playThenAsksForTheConsole() {
        // Given
        let (_, _, home) = makeHome()
        var requested: [StreamTarget] = []
        home.onPlay = { requested.append($0) }

        // When
        home.play(.dummyBedroom)

        // Then
        #expect(requested == [.console(id: "A", name: "Bedroom")])
    }

    @Test
    func refreshAccountThenAsksTheAccountToRefresh() async {
        // Given
        let (_, _, home) = makeHome()
        var refreshCount = 0
        home.onRefreshAccount = { refreshCount += 1 }

        // When
        await home.refreshAccount()

        // Then
        #expect(refreshCount == 1)
    }

    @Test
    func isPowerProblemPresentedWhenDismissedThenClearsTheProblem() async {
        // Given
        let (_, service, home) = makeHome()
        service.commandResult = .failure(URLError(.badServerResponse))

        await home.togglePower(of: .dummyLivingRoom(powerState: .on))

        let wasPresented = home.isPowerProblemPresented
        let title = home.powerProblemTitle

        // When
        home.isPowerProblemPresented = false

        // Then
        #expect(wasPresented)
        #expect(!title.isEmpty)
        #expect(home.powerProblem == nil)
        #expect(home.powerProblemTitle.isEmpty)
    }

    @Test
    func recordLastFrameWhenRelaunchedThenStaysWithItsOwnAccount() {
        // Given
        let (harness, _, home) = makeHome()

        // When
        home.recordLastFrame(.dummyRedPixels, console: "X")

        // Then
        #expect(harness.home(for: "2535", service: ConsoleServiceStub()).lastFrames["X"] != nil)
        #expect(harness.home(for: "9999", service: ConsoleServiceStub()).lastFrames.isEmpty)
    }

    @Test
    func recordLastFrameWhenAccountSignsOutThenFrameIsGone() {
        // Given
        let (harness, _, home) = makeHome()
        home.recordLastFrame(.dummyRedPixels, console: "X")

        // When
        harness.cache.removeLastFrames(for: "2535")

        // Then
        #expect(harness.home(for: "2535", service: ConsoleServiceStub()).lastFrames.isEmpty)
    }
}

private extension HomeViewModelTests {
    func makeHome(
        clock: some Clock<Duration> = ContinuousClock()
    ) -> (AppHarness, ConsoleServiceStub, HomeViewModel) {
        let harness = AppHarness()
        let service = ConsoleServiceStub()
        return (harness, service, harness.home(for: "2535", service: service, clock: clock))
    }

    func isFailed(_ state: LoadState) -> Bool {
        switch state {
        case .failed: true
        case .idle, .loading, .loaded: false
        }
    }
}
