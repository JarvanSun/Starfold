//
//  FavoritesStoreTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StarfoldShared

@MainActor
struct FavoritesStoreTests {
    @Test
    func toggleWhenRelaunchedThenKeepsFavorites() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        let store = FavoritesStore(defaults: defaults, key: "favorites.2535")

        // When
        store.toggle("ALPHA")
        store.toggle("BRAVO")
        store.toggle("BRAVO")

        // Then
        let relaunched = FavoritesStore(defaults: defaults, key: "favorites.2535")
        #expect(relaunched.titleIDs == ["ALPHA"])
    }
}
