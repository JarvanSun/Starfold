//
//  VideoHostView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
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

    override func layoutSubviews() {
        super.layoutSubviews()

        fitVideoLayerWithoutAnimation()
    }

    private func fitVideoLayerWithoutAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        renderer.systemVideo.layer.frame = bounds

        CATransaction.commit()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        keepWindowAspectRatioWhileResizing()
    }

    private func keepWindowAspectRatioWhileResizing() {
        guard let scene = window?.windowScene else { return }

        let preferences = UIWindowScene.GeometryPreferences.Vision(resizingRestrictions: .uniform)
        scene.requestGeometryUpdate(preferences) { _ in }
    }
}
