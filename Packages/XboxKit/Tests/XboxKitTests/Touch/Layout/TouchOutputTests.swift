//
//  TouchOutputTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchOutputTests {
    @Test(arguments: TouchGamepadOutput.allCases)
    func initThenReadsEveryGamepadOutput(output: TouchGamepadOutput) {
        #expect(TouchOutput(name: output.rawValue) == .gamepad(output))
    }

    @Test(arguments: TouchMouseOutput.allCases)
    func initThenReadsEveryRelativeMouseOutput(output: TouchMouseOutput) {
        #expect(TouchOutput(name: output.rawValue) == .relativeMouse(output))
    }

    @Test
    func initWhenTheNameIsUnknownThenKeepsItAsUnsupported() {
        #expect(TouchOutput(name: "absoluteMouse") == .unsupported("absoluteMouse"))
    }
}
