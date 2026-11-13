//
//  PaletteTint.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

extension View {
    func paletteTint() -> some View {
        modifier(PaletteTint())
    }
}

private struct PaletteTint: ViewModifier {
    @Environment(\.palette) private var palette

    func body(content: Content) -> some View {
        content.tint(palette.accent.color)
    }
}
