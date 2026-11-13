//
//  StreamServiceStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import XboxKit

@testable import StarfoldShared

final class StreamServiceStub: StreamService {
    var updates: [StreamUpdate] = []
    var failure: Error?
    var touchBundle: TouchBundle?
    private(set) var connectedTargets: [StreamTarget] = []
    private(set) var directStereoChanges: [Bool] = []
    private(set) var touchBundleRequests: [String] = []

    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection {
        connectedTargets.append(target)

        if let failure {
            throw failure
        }

        return StreamConnectionStub(updates: updates)
    }

    func setDirectStereo(_ isEnabled: Bool) {
        directStereoChanges.append(isEnabled)
    }

    func touchBundle(forTitle titleID: String, on target: StreamTarget) async throws -> TouchBundle?
    {
        touchBundleRequests.append(titleID)

        return touchBundle
    }
}
