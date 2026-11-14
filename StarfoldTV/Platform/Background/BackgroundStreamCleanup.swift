//
//  BackgroundStreamCleanup.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import UIKit
import os

final class BackgroundStreamCleanup {
    private let log = Logger(category: .tvLifecycle)

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func end(_ presenter: StreamPresenter) {
        guard presenter.isPresented, backgroundTask == .invalid else { return }

        let taskName = "End Xbox session"

        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: taskName) {
            [weak self] in
            self?.log.warning("Background cleanup time expired")

            self?.finish()
        }

        Task {
            await presenter.end()

            log.info(
                "Background stream cleanup returned; remote deletion outcome is in GSSVSession logs"
            )

            finish()
        }
    }

    private func finish() {
        guard backgroundTask != .invalid else { return }

        UIApplication.shared.endBackgroundTask(backgroundTask)

        backgroundTask = .invalid
    }
}
