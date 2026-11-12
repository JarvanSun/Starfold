//
//  URLDummy.swift
//  TopShelfKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension URL {
    nonisolated static var dummyWebPage: URL {
        .init(string: "https://example.com/game/X")!
    }

    nonisolated static var dummyLinkToUnknownPage: URL {
        .init(string: "starfold://settings/X")!
    }

    nonisolated static var dummyGameLinkWithoutID: URL {
        .init(string: "starfold://game/")!
    }

    static func dummyTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
