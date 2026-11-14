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

    func end(_ stop: @escaping () async -> Void) {
        guard task == .invalid else { return }

        let taskName = "End Xbox session"

        task = UIApplication.shared.beginBackgroundTask(withName: taskName) { [weak self] in
            self?.log.warning("Background streamViewModel end ran out of time")

            self?.finish()
        }

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
}
