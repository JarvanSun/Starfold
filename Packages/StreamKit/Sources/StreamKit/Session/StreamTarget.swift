//
//  StreamTarget.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum StreamTarget: Sendable, Equatable {
    case console(id: String, name: String)
    case cloud(titleID: String, name: String)

    public var name: String {
        switch self {
        case .console(_, let name), .cloud(_, let name): name
        }
    }
}
