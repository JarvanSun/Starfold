//
//  TouchAnchorExtensions.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/14.
//

import StarfoldShared
import StreamKit
import TouchController

extension TouchAnchor {
    var layoutAnchor: TCControlLayoutAnchor {
        switch self {
        case .topLeading: .topLeft
        case .top: .topCenter
        case .topTrailing: .topRight
        case .leading: .centerLeft
        case .center: .center
        case .trailing: .centerRight
        case .bottomLeading: .bottomLeft
        case .bottom: .bottomCenter
        case .bottomTrailing: .bottomRight
        }
    }
}
