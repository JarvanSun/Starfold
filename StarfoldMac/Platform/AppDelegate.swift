//
//  AppDelegate.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import AppKit
import StarfoldShared

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var app: AppViewModel?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let app, app.stream != nil else { return .terminateNow }

        Task {
            await endStream(of: app)

            sender.reply(toApplicationShouldTerminate: true)
        }

        return .terminateLater
    }
}

private extension AppDelegate {
    func endStream(of app: AppViewModel) async {
        let longestWaitForStreamEnd: Duration = .seconds(2)
        let longestWait = longestWaitForStreamEnd
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await app.endStream() }
            group.addTask { try? await Task.sleep(for: longestWait) }

            await group.next()

            group.cancelAll()
        }
    }
}
