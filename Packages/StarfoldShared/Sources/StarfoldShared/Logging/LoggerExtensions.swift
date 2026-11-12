//
//  LoggerExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import os

extension Logger {
    public init(category: LogCategory) {
        self.init(subsystem: "com.jarvansun.sunbox", category: category.rawValue)
    }
}
