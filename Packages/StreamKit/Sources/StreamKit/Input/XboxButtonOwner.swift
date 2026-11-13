//
//  XboxButtonOwner.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController

public enum XboxButtonOwner: Sendable, Equatable {
    case stream
    case system
    case unknown
}

#if !os(tvOS)
@available(macOS 27.0, iOS 27.0, visionOS 27.0, *)
extension XboxButtonOwner {
    init(inAppAction: GCControllerHomeButtonSettingsManager.InAppAction) {
        switch inAppAction {
        case .defer: self = .stream
        case .systemDefault: self = .system
        case .unavailable: self = .unknown
        default: self = Self.ownerOfPlatformSpecific(inAppAction)
        }
    }

    private static func ownerOfPlatformSpecific(
        _ inAppAction: GCControllerHomeButtonSettingsManager.InAppAction
    ) -> XboxButtonOwner {
        #if os(macOS)
        inAppAction == .disabled ? .stream : .unknown
        #else
        .unknown
        #endif
    }
}
#endif
