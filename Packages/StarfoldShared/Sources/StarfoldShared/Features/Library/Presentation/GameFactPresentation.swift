//
//  GameFactPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension GameFact {
    public var label: LocalizedStringResource {
        switch kind {
        case .genres: .init("library.game.fact.genres", bundle: .module)
        case .developer: .init("library.game.fact.developer", bundle: .module)
        case .released: .init("library.game.fact.released", bundle: .module)
        }
    }
}
