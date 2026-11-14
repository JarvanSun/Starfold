//
//  JSONPatchError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum JSONPatchError: Error, Sendable, Equatable {
    case invalidPointer(String)
    case pathNotFound(String)
    case invalidArrayIndex(String)
    case testFailed(String)
    case moveIntoDescendant(String)
}
