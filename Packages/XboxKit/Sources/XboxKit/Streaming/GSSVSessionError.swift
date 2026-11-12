//
//  GSSVSessionError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum GSSVSessionError: Error, Sendable, Equatable {
    case failed(code: String?, message: String?)
    case timedOut(String)
    case malformedResponse(String)
}
