//
//  VideoHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController
import QuartzCore
import StreamKit
import UIKit

final class VideoHostView: UIView {
    private let renderer: StreamRenderer

    init(renderer: StreamRenderer) {
        self.renderer = renderer

        super.init(frame: .zero)

        backgroundColor = .black

        layer.addSublayer(renderer.systemVideo.layer)

        claimControllerForGame()
    }

    private func claimControllerForGame() {
        let controllerEvents = GCEventInteraction()
        controllerEvents.handledEventTypes = .gamepad

        addInteraction(controllerEvents)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        fitVideoLayerWithoutAnimation()

        updateDrawableSize()
    }

    private func fitVideoLayerWithoutAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        renderer.systemVideo.layer.frame = bounds

        CATransaction.commit()
    }

    private func updateDrawableSize() {
        let scale = traitCollection.displayScale
        renderer.setDrawableSize(CGSize(width: bounds.width * scale, height: bounds.height * scale))
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        updateDrawableSize()
    }
}
