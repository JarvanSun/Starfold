//
//  GameInput.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum GameInput: Identifiable {
    case controller
    case mouseAndKeyboard
    case touch

    public var id: Self {
        self
    }
}
