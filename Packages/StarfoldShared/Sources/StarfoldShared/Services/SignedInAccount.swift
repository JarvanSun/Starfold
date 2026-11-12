//
//  SignedInAccount.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct SignedInAccount {
    let summary: AccountSummary
    let consoles: ConsoleService
    let cloudLibrary: CloudLibraryService
    let streams: StreamService

    var id: String {
        summary.id
    }

    public init(
        summary: AccountSummary,
        consoles: ConsoleService,
        cloudLibrary: CloudLibraryService,
        streams: StreamService
    ) {
        self.summary = summary
        self.consoles = consoles
        self.cloudLibrary = cloudLibrary
        self.streams = streams
    }
}
