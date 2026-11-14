//
//  AppDelegate.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import AppKit
import StarfoldShared

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var appViewModel: AppViewModel?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let appViewModel, appViewModel.streamViewModel != nil else { return .terminateNow }

        Task {
            await endStream(of: appViewModel)

            sender.reply(toApplicationShouldTerminate: true)
        }

        return .terminateLater
    }

    private func endStream(of appViewModel: AppViewModel) async {
        let longestWaitForStreamEnd: Duration = .seconds(2)
        let longestWait = longestWaitForStreamEnd
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await appViewModel.endStream() }
            group.addTask { try? await Task.sleep(for: longestWait) }

            await group.next()

            group.cancelAll()
        }
    }
}
