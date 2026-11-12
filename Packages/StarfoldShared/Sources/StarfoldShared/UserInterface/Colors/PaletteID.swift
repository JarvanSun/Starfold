//
//  PaletteID.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum PaletteID: String, CaseIterable, Sendable {
    case nebula
    case aurora
    case sunrise

    init(storedValue: String?) {
        self = storedValue.flatMap(PaletteID.init(rawValue:)) ?? .nebula
    }
}
