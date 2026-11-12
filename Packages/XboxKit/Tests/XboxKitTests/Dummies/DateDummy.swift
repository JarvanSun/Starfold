//
//  DateDummy.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension Date {
    nonisolated static var dummyTestStart: Date {
        .init(timeIntervalSince1970: 1_800_000_000)
    }
}
