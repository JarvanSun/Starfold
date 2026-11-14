//
//  VideoSurface.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import QuartzCore
import StreamKit
import UIKit

final class VideoSurface: UIView {
    private let renderer: StreamRenderer

    init(renderer: StreamRenderer) {
        self.renderer = renderer

        super.init(frame: .zero)

        backgroundColor = .black

        layer.addSublayer(renderer.systemVideoPresenter.layer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        renderer.systemVideoPresenter.layer.frame = bounds
        CATransaction.commit()
    }
}
