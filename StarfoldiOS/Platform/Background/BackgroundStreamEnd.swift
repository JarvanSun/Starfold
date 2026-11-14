//
//  BackgroundStreamEnd.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import UIKit
import os

final class BackgroundStreamEnd {
    private let log = Logger(category: .stream)

    private var task: UIBackgroundTaskIdentifier = .invalid
    private var deadline: Task<Void, Never>?

    func end(_ stop: @escaping () async -> Void) {
        guard begin(onExpiry: stop) else { return }

        endNow(stop)
    }

    private func begin(onExpiry stop: @escaping () async -> Void) -> Bool {
        guard task == .invalid else { return false }

        let taskName = "End Xbox session"

        task = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
            self?.log.warning("Background stream end ran out of time")

            self?.deadline?.cancel()
            self?.deadline = nil

            Task { await stop() }

            self?.finish()
        }

        return true
    }

    private func endNow(_ stop: @escaping () async -> Void) {
        deadline = nil

        Task {
            await stop()

            finish()
        }
    }

    private func finish() {
        guard task != .invalid else { return }

        UIApplication.shared.endBackgroundTask(task)

        task = .invalid
    }

    func endBeforeTimeRunsOut(_ stop: @escaping () async -> Void) {
        guard begin(onExpiry: stop) else { return }

        log.info("Keeping the stream while the app is in the background")

        deadline = Task { [weak self] in
            let endingMargin: TimeInterval = 5
            let longestKept: Duration = .seconds(60)
            let checkInterval: Duration = .seconds(1)
            let leftAt = ContinuousClock.now

            while UIApplication.shared.backgroundTimeRemaining > endingMargin,
                ContinuousClock.now - leftAt < longestKept
            {
                try? await Task.sleep(for: checkInterval)

                guard !Task.isCancelled else { return }
            }

            self?.log.info("Ending the stream before the background time runs out")

            self?.endNow(stop)
        }
    }

    func keepStream() {
        guard let deadline else { return }

        deadline.cancel()
        self.deadline = nil

        log.info("Back before the stream had to end")

        finish()
    }
}
