//
//  TouchStyleFieldsTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchStyleFieldsTests {
    @Test
    func initThenKeepsKnownStatesAndSkipsUnknownOrBrokenOnes() throws {
        // Given / When
        let fields = try JSONFixtureDecoder().decode(
            TouchStyleFields.self,
            from: """
                {"styles":{"default":{"faceImage":{"type":"asset","value":"Bow"}},
                 "activated":{"background":{"type":"asset","value":"Glow"}},
                 "hovered":{"opacity":0.2},"idle":{"faceImage":{"type":"icon"}}}}
                """
        )

        // Then
        #expect(
            fields.styles == [
                .default: .init(faceImage: .init(source: .asset("Bow"))),
                .activated: .init(background: .init(source: .asset("Glow"))),
            ]
        )
    }

    @Test
    func initWhenAVersionOneIconIsGivenThenUsesItAsTheDefaultFaceImage() throws {
        // Given / When
        let fields = try JSONFixtureDecoder().decode(
            TouchStyleFields.self,
            from: #"{"icon":"jump","styles":{"default":{"opacity":0.8}}}"#
        )

        // Then
        let faceImage = TouchImage(source: .icon("jump", showsActionLabel: true))
        #expect(fields.styles == [.default: .init(faceImage: faceImage, opacity: 0.8)])
    }

    @Test
    func initWhenBothIconAndFaceImageAreGivenThenKeepsTheFaceImage() throws {
        // Given / When
        let fields = try JSONFixtureDecoder().decode(
            TouchStyleFields.self,
            from:
                #"{"icon":"jump","styles":{"default":{"faceImage":{"type":"asset","value":"Bow"}}}}"#
        )

        // Then
        #expect(fields.styles[.default]?.faceImage?.source == .asset("Bow"))
    }
}
