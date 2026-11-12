//
//  SignInViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/10/01.
//

import Foundation
import Testing
import XboxKit

@testable import StarfoldShared

struct SignInViewModelTests {
    @Test
    func stepWhenNothingHasRunThenIsPreparing() {
        // Given
        let (_, _, signIn) = makeSignIn()

        // Then
        #expect(signIn.step == .preparing)
    }

    @Test
    func runWhenCodeArrivesThenShowsItAsTheCodeStep() async {
        // Given
        let (harness, _, signIn) = makeSignIn()
        harness.accountService.prompts = [.success(.dummy(userCode: "FIRST"))]

        // When
        let running = Task { await signIn.run() }
        defer { running.cancel() }

        // Then
        #expect(await Eventually().holds { waitingCode(of: signIn) == "FIRST" })
        #expect(signIn.step == .code(.init(prompt: .dummy(userCode: "FIRST"))))
    }

    @Test
    func runWhenCodeExpiresThenWaitsWithNewCode() async {
        // Given
        let (harness, _, signIn) = makeSignIn()
        harness.accountService.prompts = [
            .success(.dummy(userCode: "FIRST")),
            .success(.dummy(userCode: "SECOND")),
        ]
        harness.accountService.completions = [.failure(DeviceCodeError.expired)]

        // When
        let running = Task { await signIn.run() }
        defer { running.cancel() }

        // Then
        #expect(await Eventually().holds { waitingCode(of: signIn) == "SECOND" })
        #expect(harness.accountService.signInRequests == 2)
    }

    @Test
    func runWhenUserDeclinesThenFailsWithoutAskingForAnotherCode() async {
        // Given
        let (harness, _, signIn) = makeSignIn()
        harness.accountService.prompts = [.success(.dummy(userCode: "ONLY"))]
        harness.accountService.completions = [.failure(DeviceCodeError.declined)]

        // When
        await signIn.run()

        // Then
        let declined = String(localized: "signIn.failure.declined", bundle: .module)
        #expect(signIn.step == .failure(declined))
        #expect(harness.accountService.signInRequests == 1)
        #expect(!signIn.shouldClose)
    }

    @Test
    func runWhenAccountIsAuthorizedThenIsSignedInAndStaysOpenToShowIt() async {
        // Given
        let (harness, clock, signIn) = makeSignIn()
        harness.accountService.prompts = [.success(.dummy(userCode: "ONLY"))]
        harness.accountService.completions = [.success(.dummy(id: "2535", gamertag: "NovaPilot"))]

        // When
        let running = Task { await signIn.run() }
        defer { running.cancel() }

        // Then
        #expect(await Eventually().holds { clock.sleeperCount == 1 })
        #expect(signIn.step == .progress(.signedIn))
        #expect(!signIn.shouldClose)
        #expect(harness.app.sessionState == .signedIn)
        #expect(harness.app.accounts.map(\.gamertag) == ["NovaPilot"])
    }

    @Test
    func runWhenSuccessHasBeenShownThenShouldClose() async {
        // Given
        let (harness, clock, signIn) = makeSignIn()
        harness.accountService.prompts = [.success(.dummy(userCode: "ONLY"))]
        harness.accountService.completions = [.success(.dummy(id: "2535", gamertag: "NovaPilot"))]
        let running = Task { await signIn.run() }
        _ = await Eventually().holds { clock.sleeperCount == 1 }

        // When
        clock.advance(by: .milliseconds(900))
        await running.value

        // Then
        #expect(signIn.shouldClose)
    }

    @Test
    func runWhenCancelledWhileShowingSuccessThenDoesNotClose() async {
        // Given
        let (harness, clock, signIn) = makeSignIn()
        harness.accountService.prompts = [.success(.dummy(userCode: "ONLY"))]
        harness.accountService.completions = [.success(.dummy(id: "2535", gamertag: "NovaPilot"))]
        let running = Task { await signIn.run() }
        _ = await Eventually().holds { clock.sleeperCount == 1 }

        // When
        running.cancel()
        await running.value

        // Then
        #expect(!signIn.shouldClose)
    }

    @Test
    func retryThenStartsANewAttempt() {
        // Given
        let (_, _, signIn) = makeSignIn()
        let attempt = signIn.attempt

        // When
        signIn.retry()

        // Then
        #expect(signIn.attempt == attempt + 1)
    }

    @Test
    func runWhenRetriedAfterAFailureThenAsksForANewCode() async {
        // Given
        let (harness, _, signIn) = makeSignIn()
        harness.accountService.prompts = [
            .success(.dummy(userCode: "FIRST")),
            .success(.dummy(userCode: "SECOND")),
        ]
        harness.accountService.completions = [.failure(DeviceCodeError.declined)]
        await signIn.run()

        // When
        signIn.retry()
        let running = Task { await signIn.run() }
        defer { running.cancel() }

        // Then
        #expect(await Eventually().holds { waitingCode(of: signIn) == "SECOND" })
    }

    @Test
    func welcomeFeaturesThenListTheConsoleCloudGamingAndThePlatform() {
        // Given
        let (_, _, signIn) = makeSignIn()

        // Then
        #expect(signIn.welcomeFeatures == [.console, .cloudGaming, .platform])
    }
}

private extension SignInViewModelTests {
    func makeSignIn() -> (AppHarness, ClockStub, SignInViewModel) {
        let harness = AppHarness()
        let clock = ClockStub()
        return (harness, clock, .init(service: harness.app, clock: clock))
    }

    func waitingCode(of signIn: SignInViewModel) -> String? {
        switch signIn.phase {
        case .waiting(let prompt): prompt.userCode
        case .requesting, .finishing, .done, .failed: nil
        }
    }
}
