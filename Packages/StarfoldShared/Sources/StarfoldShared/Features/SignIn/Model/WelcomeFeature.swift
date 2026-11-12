//
//  WelcomeFeature.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum WelcomeFeature: CaseIterable, Identifiable {
    case console
    case cloudGaming
    case platform

    public var id: Self {
        self
    }
}
