//
//  StreamQualityTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import XboxKit

struct StreamQualityTests {
    @Test(arguments: [(StreamQuality.standard, "android"), (.high, "windows"), (.highest, "tizen")])
    func operatingSystemNameThenPicksTierTheServiceOffers(quality: StreamQuality, expected: String)
    {
        #expect(quality.operatingSystemName == expected)
    }
}
