//
//  KeychainStoreTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import Testing

@testable import XboxKit

struct KeychainStoreTests {
    @Test
    func readWhenWrittenThenReturnsSecret() throws {
        // Given
        let store = KeychainStore(service: "com.jarvansun.sunbox.tests")
        let key = "probe-\(UUID().uuidString)"

        // When
        try store.write(Data("hello".utf8), for: key)

        // Then
        #expect(try store.read(key) == Data("hello".utf8))

        try store.delete(key)
    }
}
