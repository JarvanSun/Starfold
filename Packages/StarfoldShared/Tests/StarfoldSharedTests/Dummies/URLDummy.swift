//
//  URLDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension URL {
    static var dummySignInPage: URL {
        URL(string: "https://www.microsoft.com/link?otc=PWMLFVSX")!
    }

    static func dummyArtwork(_ name: String) -> URL {
        URL(string: "https://example.com/artwork/\(name).jpg")!
    }
}
