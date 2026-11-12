//
//  StreamPresenterTests.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing

@testable import Starfold

@MainActor
struct StreamPresenterTests {
    @Test
    func startWhenNoControllerThenPromptsWithoutPlaying() {
        // Given
        var playCount = 0
        let presenter = makePresenter(
            play: { _ in playCount += 1 },
            isControllerConnected: { false }
        )

        // When
        presenter.start(.dummyLivingRoom)

        // Then
        #expect(presenter.isControllerPromptPresented)
        #expect(!presenter.isPresented)
        #expect(playCount == 0)
    }

    @Test
    func startPromptedStreamWhenControllerConnectedThenPresentsAndPlaysOnce() async {
        // Given
        var isControllerConnected = false
        var playCount = 0
        let played = AsyncStream<Void>.makeStream()
        let presenter = makePresenter(
            play: { _ in
                playCount += 1

                played.continuation.yield(())
            },
            isControllerConnected: { isControllerConnected }
        )
        presenter.start(.dummyLivingRoom)
        isControllerConnected = true

        // When
        presenter.startPromptedStream()
        for await _ in played.stream { break }

        // Then
        #expect(presenter.isPresented)
        #expect(!presenter.isControllerPromptPresented)
        #expect(playCount == 1)

        await presenter.end()
    }

    @Test
    func endWhenCalledTwiceDuringStartThenWaitsForStartAndStopsOnce() async {
        // Given
        var events: [String] = []
        let played = AsyncStream<Void>.makeStream()
        let presenter = makePresenter(
            play: { _ in
                events.append("start")

                played.continuation.yield(())

                do { try await Task.sleep(for: .seconds(60)) } catch {}

                events.append("start-finished")
            },
            stop: {
                events.append("stop")

                await Task.yield()
            }
        )
        presenter.start(.dummyLivingRoom)
        for await _ in played.stream { break }

        // When
        async let first: Void = presenter.end()
        async let second: Void = presenter.end()
        _ = await (first, second)

        // Then
        #expect(events == ["start", "start-finished", "stop"])
        #expect(!presenter.isPresented)
        #expect(!presenter.isEnding)
    }

    @Test
    func endWhenPresentationIDIsOutdatedThenKeepsLaterPresentation() async {
        // Given
        var stopCount = 0
        let presenter = makePresenter(stop: { stopCount += 1 })
        presenter.start(.dummy(named: "First"))
        let oldPresentation = presenter.presentationID

        await presenter.end()

        presenter.start(.dummy(named: "Second"))

        // When
        await presenter.end(presentationID: oldPresentation)

        // Then
        #expect(presenter.isPresented)
        #expect(stopCount == 1)

        await presenter.end()
    }

    @Test
    func startWhenPreviousStreamIsStoppingThenRefusesUntilStopped() async {
        // Given
        var playedNames: [String] = []
        let played = AsyncStream<Void>.makeStream()
        let stopping = AsyncStream<Void>.makeStream()
        let released = AsyncStream<Void>.makeStream()
        let presenter = makePresenter(
            play: { target in
                playedNames.append(target.name)

                played.continuation.yield(())
            },
            stop: {
                stopping.continuation.yield(())

                for await _ in released.stream { break }
            }
        )
        presenter.start(.dummy(named: "First"))
        for await _ in played.stream { break }

        let ending = Task { await presenter.end() }
        for await _ in stopping.stream { break }

        // When
        presenter.start(.dummy(named: "Too soon"))

        released.continuation.yield(())

        await ending.value

        presenter.start(.dummy(named: "Second"))
        for await _ in played.stream { break }

        // Then
        #expect(playedNames == ["First", "Second"])
        #expect(presenter.isPresented)

        released.continuation.finish()

        await presenter.end()
    }

    @Test
    func endWhenRestartAwaitsCleanupThenCancelsRestart() async {
        // Given
        var stopCount = 0
        let stopping = AsyncStream<Void>.makeStream()
        let released = AsyncStream<Void>.makeStream()
        let presenter = makePresenter(stop: {
            stopCount += 1

            stopping.continuation.yield(())

            for await _ in released.stream { break }
        })
        presenter.start(.dummyLivingRoom)
        let restart = Task { await presenter.restart() }
        for await _ in stopping.stream { break }

        // When
        Task { released.continuation.yield(()) }

        await presenter.end()

        await restart.value

        // Then
        #expect(!presenter.isPresented)
        #expect(stopCount == 1)
    }

    @Test
    func goBackWhenMenuPresentedThenClosesMenuBeforeEndingOnce() async {
        // Given
        var stopCount = 0
        let presenter = makePresenter(stop: { stopCount += 1 })
        presenter.start(.dummyLivingRoom)
        presenter.isMenuPresented = true

        // When
        await presenter.goBack()
        let isStillPresentedAfterFirstBack = presenter.isPresented && !presenter.isMenuPresented
        let stopCountAfterFirstBack = stopCount

        await presenter.goBack()

        await presenter.goBack()

        // Then
        #expect(isStillPresentedAfterFirstBack)
        #expect(stopCountAfterFirstBack == 0)
        #expect(!presenter.isPresented)
        #expect(stopCount == 1)
    }

    @Test
    func isRawInputEnabledWithoutAStreamThenIsFalse() {
        #expect(!makePresenter().isRawInputEnabled(for: nil))
    }

    @Test
    func openMenuWithoutAStreamThenStaysClosed() {
        // Given
        let presenter = makePresenter()

        // When
        presenter.openMenu(for: nil)

        // Then
        #expect(!presenter.isMenuPresented)
    }
}

private extension StreamPresenterTests {
    func makePresenter(
        play: @escaping (StreamTarget) async -> Void = { _ in },
        stop: @escaping () async -> Void = {},
        isControllerConnected: @escaping () -> Bool = { true }
    ) -> StreamPresenter {
        .init(
            play: play,
            stop: stop,
            isControllerConnected: isControllerConnected,
            isSignInExpired: { false }
        )
    }
}
