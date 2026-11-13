//
//  StreamPhasePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import SwiftUI

extension StreamPhase {
    public var arrivalFeedback: SensoryFeedback? {
        switch self {
        case .streaming: .success
        case .ended(.hostEnded): .warning
        case .ended(.connectionLost), .ended(.failed): .error
        case .ended(.userStopped), .provisioning, .queued, .connecting: nil
        }
    }
}
