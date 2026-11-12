//
//  AppViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct AppViewModelTests {
    @Test
    func restoreWhenNoAccountIsSavedThenShowsWelcome() async {
        // Given
        let harness = AppHarness()

        // When
        await harness.app.restore()

        // Then
        #expect(harness.app.sessionState == .signedOut)
        #expect(harness.app.home == nil)
        #expect(harness.app.library == nil)
    }

    @Test
    func restoreWhenSeveralAccountsAreSavedThenActivatesTheLastUsed() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "2222")

        // When
        await harness.app.restore()

        // Then
        #expect(harness.app.sessionState == .signedIn)
        #expect(harness.app.activeAccountID == "2222")
        #expect(Set(harness.app.accounts.map(\.gamertag)) == ["First", "Second"])
    }

    @Test
    func restoreWhenProfileLoadsThenReplacesStoredGamertag() async {
        // Given
        let harness = makeHarness(accounts: ["2535": "old-name"])

        // When
        await harness.app.restore()

        // Then
        #expect(await Eventually().holds { harness.app.profile != nil })
        #expect(harness.app.profile?.gamerscore == 5865)
        #expect(harness.app.accounts.first?.gamertag == "NovaPilot")
        #expect(harness.app.signedInGamertag == "NovaPilot")
    }

    @Test
    func restoreWhenProfileNeedsSignInThenAsksToSignInAgain() async {
        // Given
        let harness = makeHarness(accounts: ["2535": "NovaPilot"])
        harness.accountService.profile = .failure(XboxAccountError.signInRequired)

        // When
        await harness.app.restore()

        // Then
        #expect(await Eventually().holds { harness.app.isSignInExpired })
    }

    @Test
    func restoreThenLoadsHomeAndLibraryOfTheAccount() async {
        // Given
        let consoles = ConsoleServiceStub()
        consoles.listed = .success([.dummyLivingRoom(powerState: .on)])
        let cloudLibrary = CloudLibraryServiceStub()
        cloudLibrary.content = .success(.dummyGamePass)
        let harness = AppHarness()
        harness.accountService.savedAccounts = [
            .dummy(
                id: "2535",
                gamertag: "NovaPilot",
                consoles: consoles,
                cloudLibrary: cloudLibrary
            )
        ]

        // When
        await harness.app.restore()

        // Then
        #expect(await Eventually().holds { harness.app.home?.consolesState == .loaded })
        #expect(await Eventually().holds { harness.app.library?.cloudState == .loaded })
        #expect(harness.app.home?.consoles.map(\.name) == ["Living room"])
        #expect(harness.app.library?.games.count == 2)
    }

    @Test
    func completeSignInWhenLibraryRequestsHangThenReturnsWithoutWaitingForThem() async throws {
        // Given
        let consoles = ConsoleServiceStub()
        consoles.isHanging = true
        let cloudLibrary = CloudLibraryServiceStub()
        cloudLibrary.isHanging = true
        let harness = AppHarness()
        harness.accountService.prompts = [.success(.dummy(userCode: "ABCD1234"))]
        harness.accountService.completions = [
            .success(
                .dummy(
                    id: "2535",
                    gamertag: "NovaPilot",
                    consoles: consoles,
                    cloudLibrary: cloudLibrary
                )
            )
        ]
        let prompt = try await harness.app.beginSignIn()

        // When
        try await harness.app.completeSignIn(prompt)

        // Then
        #expect(harness.app.sessionState == .signedIn)
        #expect(harness.app.activeAccountID == "2535")
        #expect(await Eventually().holds { harness.app.home?.consolesState == .loading })
        #expect(harness.app.library?.cloudState == .loading)
    }

    @Test
    func switchAccountThenReplacesHomeAndLibraryAndRemembersAccount() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "1111")
        await harness.app.restore()
        let firstHome = harness.app.home
        let firstLibrary = harness.app.library

        // When
        await harness.app.switchAccount(to: "2222")

        // Then
        #expect(harness.app.activeAccountID == "2222")
        #expect(harness.app.home !== firstHome)
        #expect(harness.app.library !== firstLibrary)
        #expect(harness.preferences.lastAccountID == "2222")
    }

    @Test
    func signOutWhenAnotherAccountIsSavedThenSwitchesToIt() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "1111")
        await harness.app.restore()

        // When
        harness.app.signOut()

        // Then
        #expect(harness.app.activeAccountID == "2222")
        #expect(harness.app.sessionState == .signedIn)
        #expect(harness.accountService.signedOutIDs == ["1111"])
    }

    @Test
    func signOutWhenLastAccountThenShowsWelcome() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First"])
        await harness.app.restore()

        // When
        harness.app.signOut()

        // Then
        #expect(harness.app.sessionState == .signedOut)
        #expect(harness.app.home == nil)
        #expect(harness.app.library == nil)
        #expect(harness.accountService.savedAccounts.isEmpty)
    }

    @Test
    func playThenConnectsTheAccountsStreamToTheTarget() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.app.restore()

        // When
        await harness.app.play(livingRoom)

        // Then
        #expect(await Eventually().holds { harness.app.stream?.isStreaming == true })
        #expect(streams.connectedTargets == [livingRoom])
    }

    @Test
    func playThenRequestsStreamPresentation() async {
        // Given
        let harness = makeHarness(streams: StreamServiceStub(), phase: .streaming)
        await harness.app.restore()

        // When
        await harness.app.play(livingRoom)

        // Then
        #expect(harness.app.streamPresentationRequest == 1)
    }

    @Test
    func playWhenHomeAsksForAConsoleThenStartsItsStream() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.app.restore()

        // When
        harness.app.home?.play(.dummyLivingRoom(powerState: .on))

        // Then
        #expect(await Eventually().holds { streams.connectedTargets == [livingRoom] })
        #expect(harness.app.streamPresentationRequest == 1)
    }

    @Test
    func playWhenThePlatformTakesPlayRequestsThenHandsItTheTargetInstead() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.app.restore()
        var requested: [StreamTarget] = []
        harness.app.onPlayRequest = { requested.append($0) }

        // When
        harness.app.library?.play(.dummyZetaQuest)

        // Then
        #expect(requested == [.cloud(titleID: "ALPHA", name: "Zeta Quest")])
        #expect(harness.app.stream == nil)
    }

    @Test
    func playWhenSameTargetIsStreamingThenKeepsStreamAndRequestsPresentationAgain() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)
        let running = app.stream

        // When
        await app.play(livingRoom)

        // Then
        #expect(app.stream === running)
        #expect(app.streamPresentationRequest == 2)
    }

    @Test
    func playWhenAnotherTargetReplacesRunningStreamThenRequestsPresentationAgain() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)
        let running = app.stream

        // When
        await app.play(.cloud(titleID: "STARFALL", name: "Starfall"))

        // Then
        #expect(app.stream !== running)
        #expect(app.streamPresentationRequest == 2)
    }

    @Test
    func playWhenSignedOutThenRequestsNoPresentation() async {
        // Given
        let app = AppHarness().app

        // When
        await app.play(livingRoom)

        // Then
        #expect(app.stream == nil)
        #expect(app.streamPresentationRequest == 0)
    }

    @Test
    func restartStreamWhenTargetIsUnchangedThenStartsNewStream() async {
        // Given
        let harness = makeHarness(streams: StreamServiceStub(), phase: .streaming)
        await harness.app.restore()
        await harness.app.play(livingRoom)
        let running = harness.app.stream

        // When
        await harness.app.restartStream()

        // Then
        #expect(harness.app.stream !== running)
        #expect(harness.app.stream?.target == livingRoom)
        #expect(harness.app.streamPresentationRequest == 1)
    }

    @Test(arguments: [
        StreamPhase.provisioning,
        .queued(estimatedWait: nil),
        .connecting,
        .streaming,
    ])
    func needsNewStreamWhenSameTargetIsUnderwayThenIsFalse(phase: StreamPhase) async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: phase)

        // When / Then
        #expect(!app.needsNewStream(for: livingRoom))
    }

    @Test
    func needsNewStreamWhenTargetDiffersThenIsTrue() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)

        // When / Then
        #expect(app.needsNewStream(for: .cloud(titleID: "FORTNITE", name: "Fortnite")))
    }

    @Test
    func needsNewStreamWhenSameTargetEndedThenIsTrue() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .ended(.failed("x")))

        // When / Then
        #expect(app.needsNewStream(for: livingRoom))
    }

    @Test
    func needsNewStreamWhenNothingIsStreamingThenIsTrue() {
        // Given
        let app = AppHarness().app

        // When / Then
        #expect(app.needsNewStream(for: livingRoom))
    }
}

private extension AppViewModelTests {
    var livingRoom: StreamTarget {
        .console(id: "X", name: "Living room")
    }

    func makeHarness(accounts: [String: String], lastUsed lastAccountID: String? = nil)
        -> AppHarness
    {
        let harness = AppHarness()
        harness.accountService.savedAccounts = accounts.keys.sorted().map { id in
            .dummy(id: id, gamertag: accounts[id] ?? "")
        }
        harness.preferences.lastAccountID = lastAccountID
        return harness
    }

    func makeHarness(streams: StreamServiceStub, phase: StreamPhase) -> AppHarness {
        let harness = AppHarness()
        streams.updates = [.phase(phase)]
        harness.accountService.savedAccounts = [
            .dummy(id: "2535", gamertag: "NovaPilot", streams: streams)
        ]
        return harness
    }

    func makeApp(streaming target: StreamTarget, phase: StreamPhase) async -> AppViewModel {
        let harness = makeHarness(streams: StreamServiceStub(), phase: phase)
        await harness.app.restore()
        await harness.app.play(target)
        await Eventually().holds { harness.app.stream?.phase == phase }
        return harness.app
    }
}
