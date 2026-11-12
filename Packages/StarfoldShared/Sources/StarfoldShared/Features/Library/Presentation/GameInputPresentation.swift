//
//  GameInputPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension GameInput {
    public var title: LocalizedStringResource {
        switch self {
        case .controller: .init("library.game.input.controller", bundle: .module)
        case .mouseAndKeyboard: .init("library.game.input.mouseAndKeyboard", bundle: .module)
        case .touch: .init("library.game.input.touch", bundle: .module)
        }
    }

    public var symbol: String {
        switch self {
        case .controller: "gamecontroller"
        case .mouseAndKeyboard: "keyboard"
        case .touch: "hand.tap"
        }
    }
}
