//
//  PowerCommandPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension XboxLiveClient.PowerCommand {
    public var title: LocalizedStringResource {
        switch self {
        case .wakeUp: .init("home.powerCommand.wakeUp", bundle: .module)
        case .turnOff: .init("home.powerCommand.turnOff", bundle: .module)
        }
    }
}
