//
//  TouchAnchor.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics

public enum TouchAnchor: Hashable, Sendable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing

    func point(in size: CGSize) -> CGPoint {
        switch self {
        case .topLeading: CGPoint(x: 0, y: 0)
        case .top: CGPoint(x: size.width / 2, y: 0)
        case .topTrailing: CGPoint(x: size.width, y: 0)
        case .leading: CGPoint(x: 0, y: size.height / 2)
        case .center: CGPoint(x: size.width / 2, y: size.height / 2)
        case .trailing: CGPoint(x: size.width, y: size.height / 2)
        case .bottomLeading: CGPoint(x: 0, y: size.height)
        case .bottom: CGPoint(x: size.width / 2, y: size.height)
        case .bottomTrailing: CGPoint(x: size.width, y: size.height)
        }
    }
}
