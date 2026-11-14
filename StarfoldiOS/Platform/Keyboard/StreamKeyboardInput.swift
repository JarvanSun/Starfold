//
//  StreamKeyboardInput.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController
import StarfoldShared
import StreamKit
import SwiftUI

struct StreamKeyboardInput: ViewModifier {
    let streamViewModel: StreamViewModel

    func body(content: Content) -> some View {
        content
            .onAppear { listen() }
            .onReceive(NotificationCenter.default.publisher(for: .GCKeyboardDidConnect)) { _ in
                listen()
            }
            .onDisappear { stopListening() }
    }

    private func listen() {
        GCKeyboard.coalesced?.keyboardInput?.keyChangedHandler = { _, _, keyCode, isPressed in
            guard let key = KeyboardKey(keyCode: keyCode) else { return }

            MainActor.assumeIsolated {
                _ = streamViewModel.handleKey(key.rawValue, isDown: isPressed)
            }
        }
    }

    private func stopListening() {
        GCKeyboard.coalesced?.keyboardInput?.keyChangedHandler = nil

        streamViewModel.releaseKeyboard()
    }
}

extension View {
    func streamKeyboardInput(_ streamViewModel: StreamViewModel) -> some View {
        modifier(StreamKeyboardInput(streamViewModel: streamViewModel))
    }
}
