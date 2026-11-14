//
//  ControllerAvailability.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController

nonisolated struct ControllerAvailability {
    var hasConnectedController: Bool {
        !GCController.controllers().isEmpty
    }
}
