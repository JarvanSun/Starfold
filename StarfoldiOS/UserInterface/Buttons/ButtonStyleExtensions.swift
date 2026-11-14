//
//  ButtonStyleExtensions.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI

extension ButtonStyle where Self == TileButtonStyle {
    static var tile: TileButtonStyle {
        .init()
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    static var card: CardButtonStyle {
        .init()
    }
}
