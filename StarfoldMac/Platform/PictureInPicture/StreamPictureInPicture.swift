//
//  StreamPictureInPicture.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/10/01.
//

import AppKit
import GameController
import StarfoldShared
import StreamKit

final class StreamPictureInPicture {
    weak var host: StreamVideoHostView?

    private let renderer: StreamRenderer
    private let dimensions: Dimensions

    private var panel: NSPanel?
    private var isActive = false

    var isPossible: Bool {
        true
    }

    init(renderer: StreamRenderer, dimensions: Dimensions) {
        self.renderer = renderer
        self.dimensions = dimensions
    }

    func toggle() {
        switch isActive {
        case true: returnToWindow()
        case false: start()
        }
    }

    func stop() {
        guard isActive else { return }

        returnToWindow()
    }

    func dismiss() {
        guard isActive else { return }

        closePanel()
    }
}

private extension StreamPictureInPicture {
    var panelAspectRatio: NSSize {
        .init(width: 16, height: 9)
    }

    var window: NSWindow? {
        host?.window
    }

    var panelSize: NSSize {
        size(width: dimensions.pictureInPictureWidth)
    }

    var minimumPanelSize: NSSize {
        size(width: dimensions.pictureInPictureMinimumWidth)
    }

    var panelFrame: NSRect {
        let visibleFrame = (window?.screen ?? NSScreen.main)?.visibleFrame ?? fallbackVisibleFrame
        let origin = NSPoint(
            x: visibleFrame.maxX - panelSize.width - dimensions.spaceXLarge,
            y: visibleFrame.minY + dimensions.spaceXLarge
        )
        return .init(origin: origin, size: panelSize)
    }

    var fallbackVisibleFrame: NSRect {
        NSRect(origin: .zero, size: panelSize)
            .insetBy(dx: -dimensions.spaceXLarge, dy: -dimensions.spaceXLarge)
    }

    func size(width: CGFloat) -> NSSize {
        .init(width: width, height: width * panelAspectRatio.height / panelAspectRatio.width)
    }

    func start() {
        let panel = makePanel()
        panel.orderFrontRegardless()
        self.panel = panel

        window?.orderOut(nil)

        GCController.shouldMonitorBackgroundEvents = true

        isActive = true
    }

    func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: panelFrame,
            styleMask: [.borderless, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentAspectRatio = panelAspectRatio
        panel.minSize = minimumPanelSize
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.contentView = PictureInPictureView(
            renderer: renderer,
            dimensions: dimensions,
            onReturnToWindow: { [weak self] in self?.returnToWindow() },
            onClose: { [weak self] in self?.endStream() }
        )
        return panel
    }

    func returnToWindow() {
        closePanel()

        window?.makeKeyAndOrderFront(nil)

        NSApp.activate()
    }

    func closePanel() {
        panel?.orderOut(nil)
        panel?.contentView = nil
        panel = nil

        host?.reattachVideo()

        GCController.shouldMonitorBackgroundEvents = false

        isActive = false
    }

    func endStream() {
        closePanel()

        window?.close()
    }
}
