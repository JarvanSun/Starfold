//
//  BundlePathTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct BundlePathTests {
    @Test(
        arguments: [
            ("./layouts/", "layouts"),
            (#"assets\neutral\@1.0x\Bow.png"#, "assets/neutral/@1.0x/Bow.png"),
            ("/context.json", "context.json"),
            ("layouts//neutral", "layouts/neutral"),
        ]
    )
    func initThenNormalizesSeparatorsAndCurrentFolders(path: String, expected: String) {
        #expect(BundlePath(path).normalized == expected)
    }

    @Test
    func keyThenIgnoresCase() {
        #expect(
            BundlePath("Layouts/EN-us/Drive.json").key == BundlePath("layouts/en-US/drive.json").key
        )
    }
}
