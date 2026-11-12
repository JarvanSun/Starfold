//
//  FullScreenObserverView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit

final class FullScreenObserverView: NSView {
    private let report: (Bool) -> Void
    private var observers: [NSObjectProtocol] = []

    init(report: @escaping (Bool) -> Void) {
        self.report = report

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        stopObserving()

        guard let window else { return }

        observeFullScreenChanges(of: window)

        DispatchQueue.main.async { [weak self] in self?.reportFullScreen() }
    }
}

private extension FullScreenObserverView {
    var fullScreenNotifications: [Notification.Name] {
        [NSWindow.didEnterFullScreenNotification, NSWindow.didExitFullScreenNotification]
    }

    func stopObserving() {
        observers.forEach(NotificationCenter.default.removeObserver)
        observers = []
    }

    func observeFullScreenChanges(of window: NSWindow) {
        observers = fullScreenNotifications.map { name in
            NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) {
                [weak self] _ in
                MainActor.assumeIsolated { self?.reportFullScreen() }
            }
        }
    }

    func reportFullScreen() {
        report(window?.styleMask.contains(.fullScreen) ?? false)
    }
}
