//
//  PowerProblemPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension PowerProblem {
    public var title: String {
        String(localized: "library.powerProblem.title \(consoleName)", bundle: .module)
    }

    public var message: String {
        String(localized: "library.powerProblem.message", bundle: .module)
    }
}
