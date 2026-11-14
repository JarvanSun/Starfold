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
        await harness.appViewModel.restore()

        // Then
        #expect(harness.appViewModel.sessionState == .signedOut)
        #expect(harness.appViewModel.homeViewModel == nil)
        #expect(harness.appViewModel.libraryViewModel == nil)
    }

    @Test
    func restoreWhenSeveralAccountsAreSavedThenActivatesTheLastUsed() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "2222")

        // When
        await harness.appViewModel.restore()

        // Then
        #expect(harness.appViewModel.sessionState == .signedIn)
        #expect(harness.appViewModel.activeAccountID == "2222")
        #expect(Set(harness.appViewModel.accounts.map(\.gamertag)) == ["First", "Second"])
    }

    @Test
    func restoreWhenProfileLoadsThenReplacesStoredGamertag() async {
        // Given
        let harness = makeHarness(accounts: ["2535": "old-name"])

        // When
        await harness.appViewModel.restore()

        // Then
        #expect(await Eventually().holds { harness.appViewModel.profile != nil })
        #expect(harness.appViewModel.profile?.gamerscore == 5865)
        #expect(harness.appViewModel.accounts.first?.gamertag == "NovaPilot")
        #expect(harness.appViewModel.signedInGamertag == "NovaPilot")
    }

    @Test
    func restoreWhenProfileNeedsSignInThenAsksToSignInAgain() async {
        // Given
        let harness = makeHarness(accounts: ["2535": "NovaPilot"])
        harness.accountService.profile = .failure(XboxAccountError.signInRequired)

        // When
        await harness.appViewModel.restore()

        // Then
        #expect(await Eventually().holds { harness.appViewModel.isSignInExpired })
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
        await harness.appViewModel.restore()

        // Then
        #expect(
            await Eventually().holds {
                harness.appViewModel.homeViewModel?.consolesState == .loaded
            }
        )
        #expect(
            await Eventually().holds {
                harness.appViewModel.libraryViewModel?.cloudState == .loaded
            }
        )
        #expect(harness.appViewModel.homeViewModel?.consoles.map(\.name) == ["Living room"])
        #expect(harness.appViewModel.libraryViewModel?.games.count == 2)
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
        let prompt = try await harness.appViewModel.beginSignIn()

        // When
        try await harness.appViewModel.completeSignIn(prompt)

        // Then
        #expect(harness.appViewModel.sessionState == .signedIn)
        #expect(harness.appViewModel.activeAccountID == "2535")
        #expect(
            await Eventually().holds {
                harness.appViewModel.homeViewModel?.consolesState == .loading
            }
        )
        #expect(harness.appViewModel.libraryViewModel?.cloudState == .loading)
    }

    @Test
    func switchAccountThenReplacesHomeAndLibraryAndRemembersAccount() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "1111")
        await harness.appViewModel.restore()
        let firstHome = harness.appViewModel.homeViewModel
        let firstLibrary = harness.appViewModel.libraryViewModel

        // When
        await harness.appViewModel.switchAccount(to: "2222")

        // Then
        #expect(harness.appViewModel.activeAccountID == "2222")
        #expect(harness.appViewModel.homeViewModel !== firstHome)
        #expect(harness.appViewModel.libraryViewModel !== firstLibrary)
        #expect(harness.preferences.lastAccountID == "2222")
    }

    @Test
    func signOutWhenAnotherAccountIsSavedThenSwitchesToIt() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First", "2222": "Second"], lastUsed: "1111")
        await harness.appViewModel.restore()

        // When
        harness.appViewModel.signOut()

        // Then
        #expect(harness.appViewModel.activeAccountID == "2222")
        #expect(harness.appViewModel.sessionState == .signedIn)
        #expect(harness.accountService.signedOutIDs == ["1111"])
    }

    @Test
    func signOutWhenLastAccountThenShowsWelcome() async {
        // Given
        let harness = makeHarness(accounts: ["1111": "First"])
        await harness.appViewModel.restore()

        // When
        harness.appViewModel.signOut()

        // Then
        #expect(harness.appViewModel.sessionState == .signedOut)
        #expect(harness.appViewModel.homeViewModel == nil)
        #expect(harness.appViewModel.libraryViewModel == nil)
        #expect(harness.accountService.savedAccounts.isEmpty)
    }

    @Test
    func playThenConnectsTheAccountsStreamToTheTarget() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.appViewModel.restore()

        // When
        await harness.appViewModel.play(livingRoom)

        // Then
        #expect(
            await Eventually().holds { harness.appViewModel.streamViewModel?.isStreaming == true }
        )
        #expect(streams.connectedTargets == [livingRoom])
    }

    @Test
    func playThenRequestsStreamPresentation() async {
        // Given
        let harness = makeHarness(streams: StreamServiceStub(), phase: .streaming)
        await harness.appViewModel.restore()

        // When
        await harness.appViewModel.play(livingRoom)

        // Then
        #expect(harness.appViewModel.streamPresentationRequest == 1)
    }

    @Test
    func playWhenHomeAsksForAConsoleThenStartsItsStream() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.appViewModel.restore()

        // When
        harness.appViewModel.homeViewModel?.play(.dummyLivingRoom(powerState: .on))

        // Then
        #expect(await Eventually().holds { streams.connectedTargets == [livingRoom] })
        #expect(harness.appViewModel.streamPresentationRequest == 1)
    }

    @Test
    func playWhenThePlatformTakesPlayRequestsThenHandsItTheTargetInstead() async {
        // Given
        let streams = StreamServiceStub()
        let harness = makeHarness(streams: streams, phase: .streaming)
        await harness.appViewModel.restore()
        var requested: [StreamTarget] = []
        harness.appViewModel.onPlayRequest = { requested.append($0) }

        // When
        harness.appViewModel.libraryViewModel?.play(.dummyZetaQuest)

        // Then
        #expect(requested == [.cloud(titleID: "ALPHA", name: "Zeta Quest")])
        #expect(harness.appViewModel.streamViewModel == nil)
    }

    @Test
    func playWhenSameTargetIsStreamingThenKeepsStreamAndRequestsPresentationAgain() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)
        let running = app.streamViewModel

        // When
        await app.play(livingRoom)

        // Then
        #expect(app.streamViewModel === running)
        #expect(app.streamPresentationRequest == 2)
    }

    @Test
    func playWhenAnotherTargetReplacesRunningStreamThenRequestsPresentationAgain() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)
        let running = app.streamViewModel

        // When
        await app.play(.cloud(titleID: "STARFALL", name: "Starfall"))

        // Then
        #expect(app.streamViewModel !== running)
        #expect(app.streamPresentationRequest == 2)
    }

    @Test
    func playWhenSignedOutThenRequestsNoPresentation() async {
        // Given
        let app = AppHarness().appViewModel

        // When
        await app.play(livingRoom)

        // Then
        #expect(app.streamViewModel == nil)
        #expect(app.streamPresentationRequest == 0)
    }

    @Test
    func restartStreamWhenTargetIsUnchangedThenStartsNewStream() async {
        // Given
        let harness = makeHarness(streams: StreamServiceStub(), phase: .streaming)
        await harness.appViewModel.restore()
        await harness.appViewModel.play(livingRoom)
        let running = harness.appViewModel.streamViewModel

        // When
        await harness.appViewModel.restartStream()

        // Then
        #expect(harness.appViewModel.streamViewModel !== running)
        #expect(harness.appViewModel.streamViewModel?.target == livingRoom)
        #expect(harness.appViewModel.streamPresentationRequest == 1)
    }

    @Test
    func endStreamWhileAwayThenEndsTheStreamButKeepsItOnScreen() async {
        // Given
        let app = await makeApp(streaming: livingRoom, phase: .streaming)
        let running = app.streamViewModel

        // When
        await app.endStreamWhileAway()

        // Then
        #expect(app.streamViewModel === running)
        #expect(running?.phase == .ended(.leftApp))
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
        let app = AppHarness().appViewModel

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
        await harness.appViewModel.restore()
        await harness.appViewModel.play(target)
        await Eventually().holds { harness.appViewModel.streamViewModel?.phase == phase }
        return harness.appViewModel
    }
}
