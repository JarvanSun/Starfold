//
//  SessionControlling.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

protocol SessionControlling: AnyObject {
    var accounts: [AccountSummary] { get }
    var activeAccountID: String? { get }
    var signedInGamertag: String? { get }
    var needsStreamRestartForSettings: Bool { get }

    func switchAccount(to id: String) async
    func signOut()
    func restartStream() async
}
