//
//  SessionControllingStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import StarfoldShared

final class SessionControllingStub: SessionControlling {
    var accounts: [AccountSummary] = []
    var activeAccountID: String?
    var signedInGamertag: String?
    var needsStreamRestartForSettings = false
    private(set) var switchedAccountIDs: [String] = []
    private(set) var signOutCount = 0
    private(set) var streamRestartCount = 0

    func switchAccount(to id: String) async {
        switchedAccountIDs.append(id)
    }

    func signOut() {
        signOutCount += 1
    }

    func restartStream() async {
        streamRestartCount += 1
    }
}
