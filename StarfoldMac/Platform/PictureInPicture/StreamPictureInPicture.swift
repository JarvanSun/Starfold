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
    weak var videoHostView: StreamVideoHostView?

    private let renderer: StreamRenderer
    private let dimensions: Dimensions
    private let panelAspectRatio: NSSize = .init(width: 16, height: 9)

    private var panel: NSPanel?
    private var isActive = false

    var isPossible: Bool {
        true
    }

    private var window: NSWindow? {
        videoHostView?.window
    }

    init(renderer: StreamRenderer, dimensions: Dimensions) {
        self.renderer = renderer
        self.dimensions = dimensions
    }

    func toggle() {
        if isActive {
            returnToWindow()
        } else {
            start()
        }
    }

    private func returnToWindow() {
        closePanel()

        window?.makeKeyAndOrderFront(nil)

        NSApp.activate()
    }

    private func closePanel() {
        panel?.orderOut(nil)
        panel?.contentView = nil
        panel = nil

        videoHostView?.reattachVideo()

        GCController.shouldMonitorBackgroundEvents = false

        isActive = false
    }

    private func start() {
        let panel = makePanel()
        panel.orderFrontRegardless()
        self.panel = panel

        window?.orderOut(nil)

        GCController.shouldMonitorBackgroundEvents = true

        isActive = true
    }

    private func makePanel() -> NSPanel {
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

    private func endStream() {
        closePanel()

        window?.close()
    }

    private var panelFrame: NSRect {
        let fallbackVisibleFrame = NSRect(origin: .zero, size: panelSize).insetBy(
            dx: -dimensions.spaceXLarge,
            dy: -dimensions.spaceXLarge
        )
        let visibleFrame = (window?.screen ?? NSScreen.main)?.visibleFrame ?? fallbackVisibleFrame
        let origin = NSPoint(
            x: visibleFrame.maxX - panelSize.width - dimensions.spaceXLarge,
            y: visibleFrame.minY + dimensions.spaceXLarge
        )
        return .init(origin: origin, size: panelSize)
    }

    private var panelSize: NSSize {
        size(width: dimensions.pictureInPictureWidth)
    }

    private func size(width: CGFloat) -> NSSize {
        .init(width: width, height: width * panelAspectRatio.height / panelAspectRatio.width)
    }

    private var minimumPanelSize: NSSize {
        size(width: dimensions.pictureInPictureMinimumWidth)
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
