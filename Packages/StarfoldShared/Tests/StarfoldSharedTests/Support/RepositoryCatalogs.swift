//
//  RepositoryCatalogs.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

nonisolated struct RepositoryCatalogs {
    var paths: [String] {
        guard
            let enumerator = FileManager.default.enumerator(
                at: root,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )
        else {
            return []
        }

        var paths: [String] = []

        for case let url as URL in enumerator {
            if url.lastPathComponent == derivedDataFolder { enumerator.skipDescendants() }

            if url.pathExtension == catalogExtension { paths.append(relativePath(of: url)) }
        }

        return paths.sorted()
    }

    func url(for path: String) -> URL {
        root.appending(path: path)
    }
}

nonisolated private extension RepositoryCatalogs {
    var root: URL {
        .init(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    var derivedDataFolder: String { "DerivedData" }

    var catalogExtension: String { "xcstrings" }

    func relativePath(of url: URL) -> String {
        let rootPath = root.path(percentEncoded: false)
        return String(url.path(percentEncoded: false).dropFirst(rootPath.count))
    }
}
