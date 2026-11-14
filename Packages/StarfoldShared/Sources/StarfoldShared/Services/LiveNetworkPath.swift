//
//  LiveNetworkPath.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Network
import Observation

@Observable
public final class LiveNetworkPath: NetworkPathReading {
    public private(set) var isOnCellular = false
    public private(set) var hasCellular = false

    @ObservationIgnored private let monitor = NWPathMonitor()

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isOnCellular = path.usesInterfaceType(.cellular)
            let hasCellular = path.availableInterfaces.contains { $0.type == .cellular }

            Task { @MainActor in self?.apply(isOnCellular: isOnCellular, hasCellular: hasCellular) }
        }

        monitor.start(queue: .init(label: "StarfoldShared.networkPath", qos: .utility))
    }

    isolated deinit {
        monitor.cancel()
    }

    private func apply(isOnCellular: Bool, hasCellular: Bool) {
        self.isOnCellular = isOnCellular
        self.hasCellular = hasCellular
    }
}
