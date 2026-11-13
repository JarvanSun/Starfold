//
//  ConsolePresentation.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import StarfoldShared
import XboxKit

extension Console {
    func menuBarTitle(activity: ConsoleActivity?) -> LocalizedStringResource {
        switch activity {
        case let activity? where activity.kind == .playingNow:
            .init("menuBar.console.playing \(name) \(activity.name)")
        default: .init("menuBar.console.idle \(name)")
        }
    }
}
