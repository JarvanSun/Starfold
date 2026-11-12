//
//  PictureGeometryTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Testing

@testable import StreamKit

struct PictureGeometryTests {
    @Test(
        arguments: [
            (
                CGSize(width: 1920, height: 1080),
                CGSize(width: 2000, height: 2000),
                CGRect(x: 0, y: 438, width: 2000, height: 1125)
            ),
            (
                CGSize(width: 1280, height: 720),
                CGSize(width: 3000, height: 1080),
                CGRect(x: 540, y: 0, width: 1920, height: 1080)
            ),
        ]
    )
    func fittedRectThenCentresThePictureWithBars(
        content: CGSize,
        container: CGSize,
        expected: CGRect
    ) {
        #expect(PictureGeometry(content: content, container: container).fittedRect == expected)
    }

    @Test(
        arguments: [
            (CGSize(width: 3200, height: 2000), CGSize(width: 3200, height: 1800)),
            (CGSize(width: 1280, height: 720), CGSize(width: 1920, height: 1080)),
            (CGSize.zero, CGSize(width: 1920, height: 1080)),
        ]
    )
    func upscaledSizeWhenFitThenUsesTheShownSizeOnlyWhenLarger(container: CGSize, expected: CGSize)
    {
        // Given
        let geometry = PictureGeometry(
            content: CGSize(width: 1920, height: 1080),
            container: container
        )

        // When / Then
        #expect(geometry.upscaledSize(for: .fit) == expected)
    }

    @Test(
        arguments: [
            (PictureFit.fill, CGSize(width: 3556, height: 2000)),
            (PictureFit.scale, CGSize(width: 3200, height: 2000)),
        ]
    )
    func upscaledSizeWhenFillOrScaleThenCoversOrMatchesTheWindow(fit: PictureFit, expected: CGSize)
    {
        // Given
        let geometry = PictureGeometry(
            content: CGSize(width: 1920, height: 1080),
            container: CGSize(width: 3200, height: 2000)
        )

        // When / Then
        #expect(geometry.upscaledSize(for: fit) == expected)
    }
}
