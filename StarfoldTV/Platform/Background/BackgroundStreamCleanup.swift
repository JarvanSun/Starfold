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

    private var task: UIBackgroundTaskIdentifier = .invalid

    func end(_ presenter: StreamPresenter) {
        guard presenter.isPresented, task == .invalid else { return }

        let taskName = "End Xbox session"

        task = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
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
}

private extension BackgroundStreamCleanup {
    func finish() {
        guard task != .invalid else { return }

        UIApplication.shared.endBackgroundTask(task)

        task = .invalid
    }
}
