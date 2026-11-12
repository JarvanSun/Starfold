//
//  LibraryShelfPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension LibraryShelf {
    public var title: LocalizedStringResource {
        switch self {
        case .continuePlaying: .init("library.shelf.continuePlaying.title", bundle: .module)
        case .favorites: .init("library.shelf.favorites.title", bundle: .module)
        case .recentlyAdded: .init("library.shelf.recentlyAdded.title", bundle: .module)
        case .leavingSoon: .init("library.shelf.leavingSoon.title", bundle: .module)
        }
    }

    public var badge: LocalizedStringResource? {
        switch self {
        case .leavingSoon: .init("library.shelf.leavingSoon.badge", bundle: .module)
        case .continuePlaying, .favorites, .recentlyAdded: nil
        }
    }
}
