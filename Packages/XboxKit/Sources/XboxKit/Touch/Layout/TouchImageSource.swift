//
//  TouchImageSource.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchImageSource: Sendable, Hashable {
    case icon(String, showsActionLabel: Bool)
    case asset(String)
    case color(TouchColor)
    case unsupported(String)
}
