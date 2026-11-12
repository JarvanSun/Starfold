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
        consoles: ConsoleServiceStub = .init(),
        cloudLibrary: CloudLibraryServiceStub = .init(),
        streams: StreamServiceStub = .init()
    ) -> SignedInAccount {
        .init(
            summary: .init(id: id, gamertag: gamertag),
            consoles: consoles,
            cloudLibrary: cloudLibrary,
            streams: streams
        )
    }
}
