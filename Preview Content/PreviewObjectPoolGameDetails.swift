//
//  PreviewObjectPoolGameDetails.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared

extension PreviewObjectPool {
    static var gameDetailViewModel: GameDetailViewModel {
        libraryViewModel().detail(for: cloudGames[0])
    }
}
