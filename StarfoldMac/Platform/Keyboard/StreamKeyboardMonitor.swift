//
//  StreamKeyboardMonitor.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared

final class StreamKeyboardMonitor {
    var stream: StreamViewModel

    private var monitor: Any?
    private weak var view: NSView?

    init(stream: StreamViewModel) {
        self.stream = stream
    }

    func install(for view: NSView) {
        self.view = view

        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) {
            [weak self] event in
            let key = KeyEvent(event)
            let windowNumber = event.windowNumber
            let isConsumed = MainActor.assumeIsolated {
                self?.consume(key, inWindowNumber: windowNumber) ?? false
            }
            return isConsumed ? nil : event
        }
    }

    func uninstall() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }

        monitor = nil
    }
}

private struct KeyEvent: Sendable {
    enum Kind: Sendable {
        case down
        case up
        case modifiers(isShiftPressed: Bool)
        case other
    }

    let kind: Kind
    let keyCode: UInt16
    let isCommandPressed: Bool

    init(_ event: NSEvent) {
        keyCode = event.keyCode
        isCommandPressed = event.modifierFlags.contains(.command)
        kind =
            switch event.type {
            case .keyDown: .down
            case .keyUp: .up
            case .flagsChanged: .modifiers(isShiftPressed: event.modifierFlags.contains(.shift))
            default: .other
            }
    }
}

private extension StreamKeyboardMonitor {
    var leftShiftKeyCode: UInt16 {
        56
    }

    func consume(_ key: KeyEvent, inWindowNumber windowNumber: Int) -> Bool {
        guard let window = view?.window, window.windowNumber == windowNumber else { return false }

        return handle(key)
    }

    func handle(_ key: KeyEvent) -> Bool {
        guard !key.isCommandPressed else { return false }

        switch key.kind {
        case .down: return stream.handleKey(key.keyCode, isDown: true)
        case .up: return stream.handleKey(key.keyCode, isDown: false)
        case .modifiers(let isShiftPressed):
            if key.keyCode == leftShiftKeyCode {
                _ = stream.handleKey(leftShiftKeyCode, isDown: isShiftPressed)
            }

            return false
        case .other: return false
        }
    }
}
