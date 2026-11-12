//
//  LoggerExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import os

extension Logger {
    public init(category: LogCategory) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier ?? "Starfold",
            category: category.rawValue
        )
    }
}
