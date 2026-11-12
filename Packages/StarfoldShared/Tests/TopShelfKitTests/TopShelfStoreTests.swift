//
//  TopShelfStoreTests.swift
//  TopShelfKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import TopShelfKit

struct TopShelfStoreTests {
    @Test
    func saveWhenSnapshotIsNewThenStoresIt() throws {
        // Given
        let directory = try URL.dummyTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = TopShelfStore(directory: directory)

        // When
        let didChange = store.save(.dummyContinuePlaying)

        // Then
        #expect(didChange)
        #expect(store.load() == .dummyContinuePlaying)
    }

    @Test
    func saveWhenSnapshotIsUnchangedThenReportsNoChange() throws {
        // Given
        let directory = try URL.dummyTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = TopShelfStore(directory: directory)
        store.save(.dummyContinuePlaying)

        // When
        let didChange = store.save(.dummyContinuePlaying)

        // Then
        #expect(!didChange)
    }

    @Test
    func saveWhenSnapshotIsEmptyThenRemovesThePreviousRows() throws {
        // Given
        let directory = try URL.dummyTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = TopShelfStore(directory: directory)
        store.save(.dummyContinuePlaying)

        // When
        let didChange = store.save(TopShelfSnapshot())

        // Then
        #expect(didChange)
        #expect(store.load() == nil)
    }
}
