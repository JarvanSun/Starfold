//
//  StreamQualityExtensions.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

extension StreamQuality {
    var nominalSize: (width: Int, height: Int) {
        switch self {
        case .standard: (1280, 720)
        case .high: (1920, 1080)
        case .highest: (1920, 1080)
        }
    }
}
