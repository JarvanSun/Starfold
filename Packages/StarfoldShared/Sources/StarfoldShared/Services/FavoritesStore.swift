//
//  FavoritesStore.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Observation

@Observable
public final class FavoritesStore {
    private(set) var titleIDs: Set<String>

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults, key: String) {
        self.defaults = defaults
        self.key = key
        titleIDs = Set(defaults.stringArray(forKey: key) ?? [])
    }

    public func toggle(_ titleID: String) {
        if contains(titleID) {
            titleIDs.remove(titleID)
        } else {
            titleIDs.insert(titleID)
        }

        defaults.set(titleIDs.sorted(), forKey: key)
    }

    public func contains(_ titleID: String) -> Bool {
        titleIDs.contains(titleID)
    }
}
