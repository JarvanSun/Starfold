//
//  TouchControlsMode.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/14.
//

enum TouchControlsMode: Equatable {
    case hidden
    case playing(isHapticsEnabled: Bool)
    case preview
}
