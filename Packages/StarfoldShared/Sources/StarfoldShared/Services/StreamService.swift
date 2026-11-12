//
//  StreamService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

public protocol StreamService {
    func connect(to target: StreamTarget, options: StreamOptions) async throws -> StreamConnection
    func setDirectStereo(_ isEnabled: Bool)
}
