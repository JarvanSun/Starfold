//
//  HomeCardAction.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct HomeCardAction {
    let title: LocalizedStringResource
    let systemImage: String
    let isEnabled: Bool

    let onPerform: () -> Void
}
