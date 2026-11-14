//
//  StreamKeyboardMonitor.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared

final class StreamKeyboardMonitor {
    private let leftShiftKeyCode: UInt16 = 56

    var streamViewModel: StreamViewModel

    private var eventMonitor: Any?
    private weak var view: NSView?

    init(streamViewModel: StreamViewModel) {
        self.streamViewModel = streamViewModel
    }

    func install(for view: NSView) {
        self.view = view

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged])
        {
            [weak self] event in
            let keyEvent = KeyEvent(event)
            let windowNumber = event.windowNumber
            let isConsumed = MainActor.assumeIsolated {
                self?.consume(keyEvent, inWindowNumber: windowNumber) ?? false
            }
            return isConsumed ? nil : event
        }
    }

    private func consume(_ keyEvent: KeyEvent, inWindowNumber windowNumber: Int) -> Bool {
        guard let window = view?.window, window.windowNumber == windowNumber else { return false }

        return handle(keyEvent)
    }

    private func handle(_ keyEvent: KeyEvent) -> Bool {
        guard !keyEvent.isCommandPressed else { return false }

        switch keyEvent.kind {
        case .down: return streamViewModel.handleKey(keyEvent.keyCode, isDown: true)
        case .up: return streamViewModel.handleKey(keyEvent.keyCode, isDown: false)
        case .modifiers(let isShiftPressed):
            if keyEvent.keyCode == leftShiftKeyCode {
                streamViewModel.handleKey(leftShiftKeyCode, isDown: isShiftPressed)
            }

            return false
        case .other: return false
        }
    }

    func uninstall() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }

        eventMonitor = nil
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
