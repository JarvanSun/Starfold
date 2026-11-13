//
//  TouchBundleUnpacker.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import XboxKit

nonisolated struct TouchBundleUnpacker {
    @concurrent
    func bundle(from archive: Data) async throws -> TouchBundle {
        try TouchBundle(archive: archive)
    }
}
