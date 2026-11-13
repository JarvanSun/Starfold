//
//  TouchImageTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchImageTests {
    @Test(
        arguments: [
            (
                #"{"type":"icon","value":"jump"}"#,
                TouchImage(source: .icon("jump", showsActionLabel: true))
            ),
            (
                #"{"type":"icon","value":"jump","label":{"type":"none"},"opacity":0.4}"#,
                .init(source: .icon("jump", showsActionLabel: false), opacity: 0.4)
            ),
            (#"{"type":"asset","value":"Sword"}"#, .init(source: .asset("Sword"))),
            (
                ##"{"type":"color","value":"#000"}"##,
                .init(source: .color(.rgba(red: 0, green: 0, blue: 0, alpha: 1)))
            ),
            (#"{"type":"video","value":"intro"}"#, .init(source: .unsupported("video"))),
        ]
    )
    func initThenReadsIconsAssetsAndColors(json: String, expected: TouchImage) throws {
        #expect(try JSONFixtureDecoder().decode(TouchImage.self, from: json) == expected)
    }
}
