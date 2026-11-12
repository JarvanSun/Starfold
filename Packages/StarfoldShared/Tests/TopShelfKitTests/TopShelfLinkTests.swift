//
//  TopShelfLinkTests.swift
//  TopShelfKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import TopShelfKit

struct TopShelfLinkTests {
    @Test(arguments: [
        TopShelfLink.dummyPlayGame,
        TopShelfLink.dummyShowGameWithAccentedName,
        TopShelfLink.dummyConsole,
    ])
    func urlThenParsesBackToTheSameLink(link: TopShelfLink) {
        #expect(TopShelfLink(url: link.url) == link)
    }

    @Test(arguments: [URL.dummyWebPage, URL.dummyLinkToUnknownPage, URL.dummyGameLinkWithoutID])
    func initWhenURLIsNotAGameOrConsoleLinkThenIsNil(url: URL) {
        #expect(TopShelfLink(url: url) == nil)
    }
}
