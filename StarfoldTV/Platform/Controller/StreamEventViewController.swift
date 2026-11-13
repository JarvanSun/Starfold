//
//  StreamEventViewController.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import GameController
import SwiftUI
import UIKit

final class StreamEventViewController<Content: View>: GCEventViewController {
    private enum RemoteCommand {
        case back
        case playPause
    }

    let host: UIHostingController<Content>
    var isRawInputEnabled = false {
        didSet {
            guard isRawInputEnabled != oldValue else { return }

            applyRawInput()
        }
    }

    private func applyRawInput() {
        controllerUserInteractionEnabled = !isRawInputEnabled

        switch isRawInputEnabled {
        case true:
            installRemoteHandlers()

            becomeFirstResponder()
        case false:
            removeRemoteHandlers()

            resignFirstResponder()

            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        }
    }

    private func installRemoteHandlers() {
        for controller in GCController.controllers() where controller.extendedGamepad == nil {
            guard let remote = controller.microGamepad else { continue }

            if !remotes.contains(where: { $0 === controller }) { remotes.append(controller) }

            remote.buttonMenu.pressedChangedHandler = handlerOnRelease(perform: .back)
            remote.buttonX.pressedChangedHandler = handlerOnRelease(perform: .playPause)
        }
    }

    private func handlerOnRelease(perform command: RemoteCommand)
        -> GCControllerButtonValueChangedHandler
    {
        { [weak self] _, _, isPressed in
            guard !isPressed else { return }

            Task { @MainActor in
                guard let self, self.isRawInputEnabled else { return }

                self.perform(command)
            }
        }
    }

    private func perform(_ command: RemoteCommand) {
        switch command {
        case .back: onBack()
        case .playPause: onPlayPause()
        }
    }

    var onBack: @MainActor @Sendable () -> Void
    var onPlayPause: @MainActor @Sendable () -> Void

    private var controllerConnectionObserver: NSObjectProtocol?
    private var remotes: [GCController] = []

    override var canBecomeFirstResponder: Bool {
        isRawInputEnabled
    }

    init(
        rootView: Content,
        onBack: @escaping @MainActor @Sendable () -> Void,
        onPlayPause: @escaping @MainActor @Sendable () -> Void
    ) {
        host = UIHostingController(rootView: rootView)
        self.onBack = onBack
        self.onPlayPause = onPlayPause

        super.init(nibName: nil, bundle: nil)

        controllerUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    isolated deinit {
        if let controllerConnectionObserver {
            NotificationCenter.default.removeObserver(controllerConnectionObserver)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        embedHost()

        observeControllerConnections()
    }

    private func embedHost() {
        host.view.backgroundColor = .black

        addChild(host)

        host.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(host.view)

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        host.didMove(toParent: self)
    }

    private func observeControllerConnections() {
        controllerConnectionObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.adoptConnectedRemotes() }
        }
    }

    private func adoptConnectedRemotes() {
        if isRawInputEnabled { installRemoteHandlers() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isRawInputEnabled { becomeFirstResponder() }
    }

    func removeRemoteHandlers() {
        for controller in remotes {
            controller.microGamepad?.buttonMenu.pressedChangedHandler = nil
            controller.microGamepad?.buttonX.pressedChangedHandler = nil
        }

        remotes.removeAll()
    }
}
