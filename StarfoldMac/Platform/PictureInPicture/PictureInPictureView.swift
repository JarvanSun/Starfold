//
//  PictureInPictureView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import StreamKit
import SwiftUI

final class PictureInPictureView: NSView {
    private let onReturnToWindow: () -> Void

    private let renderer: StreamRenderer
    private let dimensions: Dimensions
    private let controls: NSHostingView<PictureInPictureControls>

    override var mouseDownCanMoveWindow: Bool {
        true
    }

    init(
        renderer: StreamRenderer,
        dimensions: Dimensions,
        onReturnToWindow: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.renderer = renderer
        self.dimensions = dimensions
        self.onReturnToWindow = onReturnToWindow
        controls = .init(
            rootView: PictureInPictureControls(onReturnToWindow: onReturnToWindow, onClose: onClose)
        )

        super.init(frame: .zero)

        showVideo()

        addControls()
    }

    private func showVideo() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.cornerRadius = dimensions.cornerRadiusMedium
        layer?.masksToBounds = true

        layer?.addSublayer(renderer.systemVideo.layer)
    }

    private func addControls() {
        controls.alphaValue = 0

        addSubview(controls)

        addTrackingArea(
            NSTrackingArea(
                rect: .zero,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self
            )
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        renderer.systemVideo.layer.frame = bounds
        CATransaction.commit()

        placeControls()

        updateDrawableSize()
    }

    private func placeControls() {
        let size = controls.fittingSize
        controls.frame = NSRect(
            x: bounds.maxX - size.width - dimensions.spaceSmall,
            y: bounds.maxY - size.height - dimensions.spaceSmall,
            width: size.width,
            height: size.height
        )
    }

    private func updateDrawableSize() {
        let fallbackBackingScale: CGFloat = 2
        let scale = window?.backingScaleFactor ?? fallbackBackingScale
        renderer.setDrawableSize(CGSize(width: bounds.width * scale, height: bounds.height * scale))
    }

    override func mouseEntered(with event: NSEvent) {
        fadeControls(to: 1, duration: 0.15)
    }

    private func fadeControls(to alpha: CGFloat, duration: TimeInterval) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration

            controls.animator().alphaValue = alpha
        }
    }

    override func mouseExited(with event: NSEvent) {
        fadeControls(to: 0, duration: 0.25)
    }

    override func mouseDown(with event: NSEvent) {
        switch event.clickCount {
        case 2: onReturnToWindow()
        default: super.mouseDown(with: event)
        }
    }
}
