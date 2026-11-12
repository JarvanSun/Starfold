//
//  PreviewStreamService.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared
import StreamKit

struct PreviewStreamService: StreamService {
    let updates: [StreamUpdate]

    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection {
        PreviewStreamConnection(updates: updates)
    }

    func setDirectStereo(_ isEnabled: Bool) {}
}
#endif
