//
//  FavoriteActionPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension FavoriteAction {
    public var title: LocalizedStringResource {
        switch self {
        case .add: .init("library.game.favorite.add", bundle: .module)
        case .remove: .init("library.game.favorite.remove", bundle: .module)
        }
    }

    public var symbol: String {
        switch self {
        case .add: "heart"
        case .remove: "heart.fill"
        }
    }
}
