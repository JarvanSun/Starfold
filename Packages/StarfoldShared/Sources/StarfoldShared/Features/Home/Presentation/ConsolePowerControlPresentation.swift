//
//  ConsolePowerControlPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI

extension ConsolePowerControl {
    public func feedback(after previous: ConsolePowerControl) -> SensoryFeedback? {
        switch (previous, self) {
        case (.sending(let sent), .command(let next)) where next != sent: .success
        default: nil
        }
    }
}
