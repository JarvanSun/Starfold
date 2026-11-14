//
//  PreviewNetworkPath.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

#if DEBUG
import StarfoldShared

struct PreviewNetworkPath: NetworkPathReading {
    var isOnCellular: Bool {
        false
    }

    var hasCellular: Bool {
        true
    }
}
#endif
