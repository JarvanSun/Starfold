//
//  PictureGeometry.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics

struct PictureGeometry {
    let content: CGSize
    let container: CGSize

    var fittedRect: CGRect {
        guard hasArea else { return CGRect(origin: .zero, size: container) }

        let scale = min(container.width / content.width, container.height / content.height)
        let size = CGSize(
            width: (content.width * scale).rounded(),
            height: (content.height * scale).rounded()
        )
        let origin = CGPoint(
            x: ((container.width - size.width) / 2).rounded(),
            y: ((container.height - size.height) / 2).rounded()
        )
        return CGRect(origin: origin, size: size)
    }

    private var hasArea: Bool {
        content.width > 0 && content.height > 0 && container.width > 0 && container.height > 0
    }

    func upscaledSize(for fit: PictureFit) -> CGSize {
        let shown =
            switch fit {
            case .fit: fittedRect.size
            case .fill: coverSize
            case .scale: container
            }
        guard shown.width > content.width, shown.height > content.height else { return content }

        return shown
    }

    private var coverSize: CGSize {
        guard hasArea else { return content }

        let scale = max(container.width / content.width, container.height / content.height)
        return CGSize(
            width: (content.width * scale).rounded(),
            height: (content.height * scale).rounded()
        )
    }
}
