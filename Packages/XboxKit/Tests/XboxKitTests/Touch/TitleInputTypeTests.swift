//
//  TitleInputTypeTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TitleInputTypeTests {
    @Test(
        arguments: [
            ("Controller", TitleInputType.controller),
            ("MKB", .mouseAndKeyboard),
            ("CustomTouchOverlay", .customTouchOverlay),
            ("GenericTouch", .genericTouch),
            ("NativeTouch", .nativeTouch),
            ("NativeSensor", .nativeSensor),
            ("nativeTouch", .unrecognized("nativeTouch")),
        ]
    )
    func initThenMapsTheServiceName(name: String, expected: TitleInputType) {
        #expect(TitleInputType(name: name) == expected)
    }
}
