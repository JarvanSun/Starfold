//
//  URLDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension URL {
    nonisolated static var dummyConsoleArtwork: URL {
        .init(string: "https://example.com/last.jpg")!
    }
}
