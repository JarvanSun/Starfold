//
//  TouchLayoutError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchLayoutError: Error, Sendable, Equatable {
    case malformedJSON(String)
    case unresolvedReference(String)
    case referenceCycle(String)
    case invalidLayout(String)
}
