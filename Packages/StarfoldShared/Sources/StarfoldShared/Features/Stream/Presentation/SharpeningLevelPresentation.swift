//
//  SharpeningLevelPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension SharpeningLevel {
    public var title: LocalizedStringResource {
        switch self {
        case .off: .init("stream.sharpening.off", bundle: .module)
        case .low: .init("stream.sharpening.low", bundle: .module)
        case .medium: .init("stream.sharpening.medium", bundle: .module)
        case .high: .init("stream.sharpening.high", bundle: .module)
        }
    }
}
