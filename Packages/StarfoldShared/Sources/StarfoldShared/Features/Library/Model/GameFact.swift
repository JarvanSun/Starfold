//
//  GameFact.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct GameFact: Identifiable, Equatable {
    public enum Kind {
        case genres
        case developer
        case released
    }

    public let kind: Kind
    public let value: String

    public var id: Kind {
        kind
    }
}
