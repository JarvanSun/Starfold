//
//  TopShelfStore.swift
//  TopShelfKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public nonisolated struct TopShelfStore: Sendable {
    private enum AppGroupID: String {
        case starfold = "group.com.jarvansun.sunbox"
    }

    private let directory: URL?

    init(directory: URL?) {
        self.directory = directory
    }

    public init() {
        self.init(
            directory: FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: AppGroupID.starfold.rawValue
            )
        )
    }

    public func load() -> TopShelfSnapshot? {
        guard let file, let data = try? Data(contentsOf: file) else { return nil }

        return try? JSONDecoder().decode(TopShelfSnapshot.self, from: data)
    }

    @discardableResult
    public func save(_ snapshot: TopShelfSnapshot) -> Bool {
        guard let file, load() != snapshot else { return false }

        switch snapshot.isEmpty {
        case true: try? FileManager.default.removeItem(at: file)
        case false: write(snapshot, to: file)
        }

        return true
    }
}

nonisolated private extension TopShelfStore {
    var fileName: String {
        "TopShelf.json"
    }

    var file: URL? {
        directory?.appending(path: fileName)
    }

    func write(_ snapshot: TopShelfSnapshot, to file: URL) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }

        try? data.write(to: file, options: .atomic)
    }
}
