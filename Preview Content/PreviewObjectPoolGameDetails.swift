//
//  PreviewObjectPoolGameDetails.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared

extension PreviewObjectPool {
    static var gameDetailViewModel: GameDetailViewModel {
        libraryViewModel().makeGameDetailViewModel(for: cloudGames[0])
    }
}
#endif
