//
//  SignedInAccount.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct SignedInAccount {
    let summary: AccountSummary
    let consoleService: ConsoleService
    let cloudLibraryService: CloudLibraryService
    let streamService: StreamService

    var id: String {
        summary.id
    }

    public init(
        summary: AccountSummary,
        consoleService: ConsoleService,
        cloudLibraryService: CloudLibraryService,
        streamService: StreamService
    ) {
        self.summary = summary
        self.consoleService = consoleService
        self.cloudLibraryService = cloudLibraryService
        self.streamService = streamService
    }
}
