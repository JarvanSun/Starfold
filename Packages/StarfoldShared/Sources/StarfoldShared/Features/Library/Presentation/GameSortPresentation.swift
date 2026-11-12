//
//  GameSortPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension GameSort {
    public var title: LocalizedStringResource {
        switch self {
        case .name: .init("library.sort.name", bundle: .module)
        case .recent: .init("library.sort.recentlyPlayed", bundle: .module)
        }
    }

    public var symbol: String {
        switch self {
        case .name: "textformat"
        case .recent: "clock"
        }
    }
}
