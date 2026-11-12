//
//  StreamRendererTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

@MainActor
struct StreamRendererTests {
    @Test
    func initThenLoadsTheShadersAndCreatesItsPipelines() {
        #expect(StreamRenderer(keepsLastFrame: true) != nil)
    }

    @Test

    func lastFrameImageWhenNoFrameRenderedThenIsNil() throws {
        // Given
        let renderer = try #require(StreamRenderer(keepsLastFrame: true))

        // When / Then
        #expect(renderer.lastFrameImage() == nil)
    }
}
