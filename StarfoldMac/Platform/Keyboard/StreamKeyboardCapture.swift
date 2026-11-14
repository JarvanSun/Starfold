//
//  StreamKeyboardCapture.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import SwiftUI

struct StreamKeyboardCapture: NSViewRepresentable {
    let streamViewModel: StreamViewModel

    static func dismantleNSView(_ view: NSView, coordinator: StreamKeyboardMonitor) {
        coordinator.uninstall()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.install(for: view)

        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.streamViewModel = streamViewModel
    }

    func makeCoordinator() -> StreamKeyboardMonitor {
        .init(streamViewModel: streamViewModel)
    }
}
