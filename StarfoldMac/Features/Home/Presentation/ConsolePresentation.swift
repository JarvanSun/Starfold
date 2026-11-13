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
    func playingTitle(activity: ConsoleActivity?) -> LocalizedStringResource? {
        guard let activity, activity.kind == .playingNow else { return nil }

        return .init("menuBar.console.playing \(name) \(activity.name)")
    }
}
