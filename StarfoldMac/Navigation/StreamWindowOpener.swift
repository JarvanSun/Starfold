//
//  StreamWindowOpener.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import SwiftUI

extension View {
    func opensStreamWindow() -> some View {
        modifier(StreamWindowOpener())
    }
}

private struct StreamWindowOpener: ViewModifier {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.openWindow) private var openWindow

    func body(content: Content) -> some View {
        content
            .onChange(of: appViewModel.streamPresentationRequest) { openStreamWindow() }
    }

    private func openStreamWindow() {
        openWindow(id: SceneID.stream.rawValue)

        NSApp.activate()
    }
}
