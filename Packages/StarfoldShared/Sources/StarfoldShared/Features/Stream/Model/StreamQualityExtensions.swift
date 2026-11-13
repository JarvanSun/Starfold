//
//  StreamQualityExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import XboxKit

extension StreamQuality {
    func capped(at ceiling: QualityChoice) -> StreamQuality {
        switch ceiling {
        case .automatic: self
        case .fixed(let limit): rank <= limit.rank ? self : limit
        }
    }

    private var rank: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
