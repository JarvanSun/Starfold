//
//  StreamEndReasonPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import SwiftUI

extension StreamEndReason {
    public var title: LocalizedStringResource {
        switch self {
        case .userStopped: .init("stream.end.userStopped.title", bundle: .module)
        case .hostEnded: .init("stream.end.hostEnded.title", bundle: .module)
        case .connectionLost: .init("stream.end.connectionLost.title", bundle: .module)
        case .failed: .init("stream.end.failed.title", bundle: .module)
        }
    }

    public var systemImage: String {
        switch self {
        case .userStopped, .hostEnded: "stop.circle.fill"
        case .connectionLost, .failed: "exclamationmark.triangle.fill"
        }
    }

    public var symbolStyle: AnyShapeStyle {
        switch self {
        case .userStopped, .hostEnded: .init(.secondary)
        case .connectionLost, .failed: .init(Color.attention)
        }
    }
}
