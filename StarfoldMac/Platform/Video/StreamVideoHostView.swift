//
//  StreamVideoHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StreamKit

final class StreamVideoHostView: NSView {
    private let renderer: StreamRenderer

    private var refreshLink: CADisplayLink?

    init(renderer: StreamRenderer) {
        self.renderer = renderer

        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        layer?.addSublayer(renderer.systemVideo.layer)

        layerContentsRedrawPolicy = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        refreshLink?.invalidate()
        refreshLink = nil

        guard window != nil else { return }

        holdHighRefreshRate()
    }

    private func holdHighRefreshRate() {
        let link = displayLink(target: self, selector: #selector(compositeFrame(_:)))
        let compositingRates: CAFrameRateRange = .init(minimum: 60, maximum: 120, preferred: 120)

        link.preferredFrameRateRange = compositingRates

        link.add(to: .main, forMode: .common)

        refreshLink = link
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        renderer.systemVideo.layer.frame = bounds
        CATransaction.commit()

        updateDrawableSize()
    }

    override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()

        updateDrawableSize()
    }

    func reattachVideo() {
        layer?.addSublayer(renderer.systemVideo.layer)

        needsLayout = true
        layoutSubtreeIfNeeded()

        updateDrawableSize()
    }

    private func updateDrawableSize() {
        let fallbackBackingScale: CGFloat = 2
        let scale = window?.backingScaleFactor ?? fallbackBackingScale
        renderer.setDrawableSize(CGSize(width: bounds.width * scale, height: bounds.height * scale))
    }
}

private extension StreamVideoHostView {
    @objc func compositeFrame(_ link: CADisplayLink) {}
}
