//
//  PacingModePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

extension PacingMode {
    public var title: LocalizedStringResource {
        switch self {
        case .standard: .init("stream.pacing.standard", bundle: .module)
        case .lowLatency: .init("stream.pacing.lowLatency", bundle: .module)
        }
    }
}
