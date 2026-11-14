//
//  TouchLayoutEditorCover.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/14.
//

import StarfoldShared
import SwiftUI

extension View {
    func touchLayoutEditorCover(
        isPresented: Binding<Bool>,
        settingsViewModel: SettingsViewModel
    ) -> some View {
        modifier(
            TouchLayoutEditorCover(isPresented: isPresented, settingsViewModel: settingsViewModel)
        )
    }
}

private struct TouchLayoutEditorCover: ViewModifier {
    @Binding var isPresented: Bool

    let settingsViewModel: SettingsViewModel

    func body(content: Content) -> some View {
        content.fullScreenCover(isPresented: $isPresented) {
            settingsViewModel.finishEditingTouchLayout()
        } content: {
            editor
        }
    }

    @ViewBuilder
    private var editor: some View {
        if let touchLayoutEditorViewModel = settingsViewModel.touchLayoutEditorViewModel {
            TouchLayoutEditorView(touchLayoutEditorViewModel: touchLayoutEditorViewModel)
        }
    }
}
