//
//  SignInStep.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum SignInStep: Equatable {
    case preparing
    case code(SignInCode)
    case progress(SignInProgress)
    case failure(String)
}
