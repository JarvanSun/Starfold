//
//  RunningTitle.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct RunningTitle: Sendable, Equatable {
    public let titleID: String
    public let isFocused: Bool

    public init(titleID: String, isFocused: Bool) {
        self.titleID = titleID
        self.isFocused = isFocused
    }
}
