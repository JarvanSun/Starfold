//
//  TouchControlsViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Observation
import StreamKit

@Observable
public final class TouchControlsViewModel {
    public private(set) var layout: TouchLayoutReference = .standard
    public private(set) var isHiddenByGame = false

    private let controllers: ControllerHub

    public var isShowing: Bool {
        controllers.activeInput == .touch && !isHiddenByGame
    }

    init(controllers: ControllerHub) {
        self.controllers = controllers
    }

    public func reveal() {
        controllers.useTouchControls()
    }

    func apply(_ command: TouchControlsCommand) {
        switch command {
        case .showLayout(let reference, _): show(reference)
        case .patchState: break
        case .hide: isHiddenByGame = true
        }
    }

    private func show(_ reference: TouchLayoutReference) {
        layout = reference
        isHiddenByGame = false
    }
}
