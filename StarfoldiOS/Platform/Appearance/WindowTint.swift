//
//  WindowTint.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import UIKit

extension View {
    func windowTint() -> some View {
        modifier(WindowTint())
    }
}

private struct WindowTint: ViewModifier {
    @Environment(\.palette) private var palette

    func body(content: Content) -> some View {
        content.onChange(of: palette.id, initial: true) { tintWindows() }
    }

    private func tintWindows() {
        let tint = UIColor(palette.accent.color)

        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows {
                window.tintColor = tint
            }
        }
    }
}
