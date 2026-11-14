//
//  TouchControlsCommand.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

public enum TouchControlsCommand: Sendable, Equatable {
    case showLayout(TouchLayoutReference, statePatch: Data?)
    case patchState(Data)
    case hide
}
