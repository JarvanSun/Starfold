//
//  LibraryShelf.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum LibraryShelf: CaseIterable, Identifiable {
    case continuePlaying
    case favorites
    case recentlyAdded
    case leavingSoon

    public var id: Self {
        self
    }
}
