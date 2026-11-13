//
//  AppPalette.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension View {
    public func appPalette() -> some View {
        modifier(AppPalette(tinting: .accent))
    }

    public func untintedAppPalette() -> some View {
        modifier(AppPalette(tinting: .system))
    }
}

private struct AppPalette: ViewModifier {
    enum Tinting {
        case accent
        case system
    }

    @Environment(AppViewModel.self) private var app

    let tinting: Tinting

    @ViewBuilder
    func body(content: Content) -> some View {
        switch tinting {
        case .accent: content.palette(chosenPalette)
        case .system: content.untintedPalette(chosenPalette)
        }
    }

    private var chosenPalette: Palette {
        .init(app.settings.palette)
    }
}
