//
//  StreamPresenter.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Observation
import StarfoldShared
import StreamKit
import os

@Observable
final class StreamPresenter {
    var isMenuPresented = false
    var isControllerPromptPresented = false

    private(set) var isPresented = false
    private(set) var isEnding = false
    private(set) var presentationID = 0
    private(set) var isInForeground = true

    private let play: (StreamTarget) async -> Void
    private let stop: () async -> Void
    private let isControllerConnected: () -> Bool
    private let isSignInExpired: () -> Bool
    private let log = Logger(category: .tvRemote)

    private var target: StreamTarget?
    private var startTask: Task<Void, Never>?
    private var endTask: Task<Void, Never>?
    private var restartRequest = 0

    var hasController: Bool {
        isControllerConnected()
    }

    private var isUnobstructed: Bool {
        !isEnding && !isSignInExpired()
    }

    init(
        play: @escaping (StreamTarget) async -> Void,
        stop: @escaping () async -> Void,
        isControllerConnected: @escaping () -> Bool,
        isSignInExpired: @escaping () -> Bool
    ) {
        self.play = play
        self.stop = stop
        self.isControllerConnected = isControllerConnected
        self.isSignInExpired = isSignInExpired
    }

    convenience init(appViewModel: AppViewModel) {
        self.init(
            play: { await appViewModel.play($0) },
            stop: { await appViewModel.endStream() },
            isControllerConnected: { !appViewModel.controllers.connected.isEmpty },
            isSignInExpired: { appViewModel.isSignInExpired }
        )
    }

    func start(_ target: StreamTarget) {
        guard !isEnding, !isPresented else { return }

        self.target = target

        switch isControllerConnected() {
        case true: present(target)
        case false: isControllerPromptPresented = true
        }
    }

    private func present(_ target: StreamTarget) {
        isControllerPromptPresented = false
        isMenuPresented = false
        isPresented = true
        presentationID += 1

        let presentation = presentationID
        startTask = Task {
            await play(target)

            if presentation == presentationID { startTask = nil }
        }
    }

    func startPromptedStream() {
        guard let target else { return }

        start(target)
    }

    func openMenu(for stream: StreamViewModel?) {
        guard canOpenMenu(for: stream) else { return }

        isMenuPresented = true

        log.info("Play/Pause opened control menu")
    }

    func goBack() async {
        log.info("Back received: menu=\(self.isMenuPresented)")

        guard !isEnding else { return }

        switch isMenuPresented {
        case true: isMenuPresented = false
        case false: await end()
        }
    }

    func restart() async {
        guard !isEnding, let target else { return }

        restartRequest += 1
        let request = restartRequest

        await finish()

        let isStillRequested = !Task.isCancelled && request == restartRequest
        if isStillRequested { start(target) }
    }

    func end() async {
        restartRequest += 1

        await finish()
    }

    private func finish() async {
        switch endTask {
        case let endTask?: await endTask.value
        case nil: await stopPresentedStream()
        }
    }

    private func stopPresentedStream() async {
        guard isPresented else { return }

        isEnding = true
        presentationID += 1

        let pendingStart = startTask
        startTask = nil
        pendingStart?.cancel()

        let stopping = Task {
            await pendingStart?.value

            await stop()
        }
        endTask = stopping

        await stopping.value

        endTask = nil
        isPresented = false
        isMenuPresented = false
        isEnding = false
    }

    func end(presentationID: Int) async {
        guard presentationID == self.presentationID else { return }

        await end()
    }

    func moveToForeground(_ isInForeground: Bool) {
        self.isInForeground = isInForeground
    }

    func isRawInputEnabled(for stream: StreamViewModel?) -> Bool {
        guard let stream, isUnobstructed else { return false }

        return stream.isPlayable && !isMenuPresented && isInForeground
    }

    func canOpenMenu(for stream: StreamViewModel?) -> Bool {
        guard let stream, isUnobstructed else { return false }

        return stream.canOpenMenu
    }
}
