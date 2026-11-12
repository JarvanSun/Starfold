//
//  LoggerExtensions.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import os

extension Logger {
    init(category: LogCategory) {
        self.init(subsystem: "com.jarvansun.sunbox", category: category.rawValue)
    }
}
