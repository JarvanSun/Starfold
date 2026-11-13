//
//  LiveNetworkPath.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Network
import os

public final class LiveNetworkPath: NetworkPathReading {
    private let monitor = NWPathMonitor()
    private let cellular = OSAllocatedUnfairLock(initialState: CellularState())

    public var isOnCellular: Bool {
        cellular.withLock { $0.isInUse }
    }

    public var hasCellular: Bool {
        cellular.withLock { $0.isAvailable }
    }

    public init() {
        monitor.pathUpdateHandler = { [cellular] path in
            cellular.withLock { $0 = CellularState(path: path) }
        }

        monitor.start(queue: .init(label: "StarfoldShared.networkPath", qos: .utility))
    }

    deinit {
        monitor.cancel()
    }
}

private nonisolated struct CellularState: Sendable {
    var isInUse = false
    var isAvailable = false

    init() {}

    init(path: NWPath) {
        isInUse = path.usesInterfaceType(.cellular)
        isAvailable = path.availableInterfaces.contains { $0.type == .cellular }
    }
}
