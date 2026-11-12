//
//  PictureFit.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum PictureFit: String, CaseIterable, Sendable {
    case fit
    case fill
    case scale

    public init(storedValue: String?) {
        self = storedValue.flatMap(PictureFit.init(rawValue:)) ?? .fit
    }
}
