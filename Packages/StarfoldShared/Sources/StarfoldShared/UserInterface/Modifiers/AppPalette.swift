//
//  AppPalette.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension View {
    public func appPalette() -> some View {
        modifier(AppPalette())
    }
}

private struct AppPalette: ViewModifier {
    @Environment(AppViewModel.self) private var app

    func body(content: Content) -> some View {
        content.palette(Palette(app.settings.palette))
    }
}
