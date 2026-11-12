//
//  StreamBackdrop.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum StreamBackdrop: Equatable {
    case game(heroImage: URL?)
    case console(type: String)
}
