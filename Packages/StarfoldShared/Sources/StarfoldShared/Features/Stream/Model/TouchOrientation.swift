//
//  TouchOrientation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

public enum TouchOrientation: String, Hashable, Sendable {
    case portrait
    case landscape

    public init(size: CGSize) {
        self = size.width > size.height ? .landscape : .portrait
    }
}
