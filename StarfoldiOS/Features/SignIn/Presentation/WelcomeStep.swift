//
//  WelcomeStep.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

enum WelcomeStep: CaseIterable, Identifiable {
    case signIn
    case choose
    case play

    var id: Self {
        self
    }

    var systemImage: String {
        switch self {
        case .signIn: "person.crop.circle"
        case .choose: "play.rectangle"
        case .play: "gamecontroller"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .signIn: .init("welcome.step.signIn")
        case .choose: .init("welcome.step.choose")
        case .play: .init("welcome.step.play")
        }
    }
}
