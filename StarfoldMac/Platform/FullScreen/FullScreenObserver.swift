//
//  FullScreenObserver.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import SwiftUI

struct FullScreenObserver: NSViewRepresentable {
    @Binding var isFullScreen: Bool

    func makeNSView(context: Context) -> FullScreenObserverView {
        .init { isFullScreen = $0 }
    }

    func updateNSView(_ view: FullScreenObserverView, context: Context) {}
}
