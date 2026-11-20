//
//  StreamQualityPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

extension StreamQuality {
    public var label: String {
        switch self {
        case .standard: "720p"
        case .high: "1080p"
        case .highest: "1440p"
        }
    }
}
