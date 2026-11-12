//
//  ConsolePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension Console {
    public var powerStateDescription: LocalizedStringResource {
        switch powerState {
        case .on: .init("library.console.powerState.on", bundle: .module)
        case .connectedStandby: .init("library.console.powerState.sleeping", bundle: .module)
        case .off: .init("library.console.powerState.off", bundle: .module)
        case .unknown: .init("library.console.powerState.unknown", bundle: .module)
        }
    }

    public var modelName: String {
        switch consoleType {
        case "XboxSeriesX": "Xbox Series X"
        case "XboxSeriesS": "Xbox Series S"
        case "XboxOneX": "Xbox One X"
        case "XboxOneS": "Xbox One S"
        case "XboxOne": "Xbox One"
        default: consoleType
        }
    }
}
