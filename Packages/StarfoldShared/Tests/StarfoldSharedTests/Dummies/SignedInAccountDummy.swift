//
//  SignedInAccountDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import StarfoldShared

extension SignedInAccount {
    static func dummy(
        id: String,
        gamertag: String,
        consoleService: ConsoleServiceStub = .init(),
        cloudLibraryService: CloudLibraryServiceStub = .init(),
        streamService: StreamServiceStub = .init()
    ) -> SignedInAccount {
        .init(
            summary: .init(id: id, gamertag: gamertag),
            consoleService: consoleService,
            cloudLibraryService: cloudLibraryService,
            streamService: streamService
        )
    }
}
