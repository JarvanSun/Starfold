//
//  PreviewStreamService.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared
import StreamKit
import XboxKit

struct PreviewStreamService: StreamService {
    let updates: [StreamUpdate]

    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection {
        PreviewStreamConnection(updates: updates)
    }

    func setDirectStereo(_ isEnabled: Bool) {}

    func touchBundle(forTitle titleID: String, on target: StreamTarget) async throws -> TouchBundle?
    {
        nil
    }
}
#endif
