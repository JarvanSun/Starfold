//
//  QualityChoice.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public enum QualityChoice: Hashable, Sendable {
    case automatic
    case fixed(StreamQuality)

    public var storageValue: String {
        switch self {
        case .automatic: automaticStorageValue
        case .fixed(let quality): quality.rawValue
        }
    }

    private var automaticStorageValue: String { "automatic" }

    public var requestedQuality: StreamQuality {
        switch self {
        case .automatic: .high
        case .fixed(let quality): quality
        }
    }

    public init(storageValue: String?) {
        switch storageValue.flatMap(StreamQuality.init(rawValue:)) {
        case let quality?: self = .fixed(quality)
        case nil: self = .automatic
        }
    }
}
