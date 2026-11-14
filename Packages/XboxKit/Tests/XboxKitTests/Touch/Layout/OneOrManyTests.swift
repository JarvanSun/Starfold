//
//  OneOrManyTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct OneOrManyTests {
    @Test(arguments: [("7", [7]), ("[1,2]", [1, 2]), ("[]", [])])
    func initThenReadsASingleValueOrAList(json: String, expected: [Int]) throws {
        #expect(
            try JSONFixtureDecoder().decode(OneOrMany<Int>.self, from: json).elements == expected
        )
    }
}
