//
//  InMemorySecretStoreTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct InMemorySecretStoreTests {
    @Test
    func writeThenReadReturnsSecretAndKeyIsListed() throws {
        // Given
        let store = InMemorySecretStore()

        // When
        try store.write(Data("secret".utf8), for: "account.2535")

        // Then
        #expect(try store.read("account.2535") == Data("secret".utf8))
        #expect(try store.allKeys() == ["account.2535"])
    }

    @Test
    func deleteThenReadIsNil() throws {
        // Given
        let store = InMemorySecretStore()
        try store.write(Data("secret".utf8), for: "account.2535")

        // When
        try store.delete("account.2535")

        // Then
        #expect(try store.read("account.2535") == nil)
    }
}
