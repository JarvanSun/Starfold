//
//  TeredoAddressTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct TeredoAddressTests {
    @Test(arguments: ["2001:0:4136:e378:8000:2bce:34ff:8efa", "2001::8000:2bce:34ff:8efa"])
    func initThenDecodesClientAddressAndMappedPort(address: String) throws {
        // Given / When
        let teredo = try #require(TeredoAddress(address))

        // Then
        #expect(teredo.publicIPv4Address == "203.0.113.5")
        #expect(teredo.mappedPort == 54321)
    }

    @Test
    func initWhenAddressIsNotTeredoThenIsNil() {
        #expect(TeredoAddress("2002:0:4136:e378:8000:2bce:34ff:8efa") == nil)
    }
}
