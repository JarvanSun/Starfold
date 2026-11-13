//
//  TouchBundleFiles.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct TouchBundleFiles: Sendable {
    private let contentsByKey: [String: Data]
    private let paths: [BundlePath]
    private let manifestPath = "takxmanifest.json"

    init(archive: Data) throws(TouchBundleError) {
        var contentsByKey: [String: Data] = [:]
        var paths: [BundlePath] = []

        do throws(ZipArchiveError) {
            let zip = try ZipArchive(archive)

            for name in zip.entryNames {
                let path = BundlePath(name)
                contentsByKey[path.key] = try zip.contents(of: name)
                paths.append(path)
            }
        } catch {
            throw .invalidArchive(error)
        }

        self.contentsByKey = contentsByKey
        self.paths = paths
    }

    func manifest() throws(TouchBundleError) -> TouchBundleManifest {
        guard let json = contents(at: manifestPath) else { throw .missingManifest }

        do {
            return try TouchJSONDecoder().decode(TouchBundleManifest.self, from: json)
        } catch {
            throw .invalidManifest(String(describing: error))
        }
    }

    func context(at path: String) throws(TouchBundleError) -> TouchContext {
        guard let json = contents(at: path) else { return .init() }

        let document: JSONValue

        do {
            document = try TouchJSONDecoder().decode(JSONValue.self, from: json)
        } catch {
            throw .invalidContext(String(describing: error))
        }

        guard case .object(let members) = document else {
            throw .invalidContext("The context is not a JSON object")
        }

        return .init(members: members)
    }

    func contents(at path: String) -> Data? {
        contentsByKey[BundlePath(path).key]
    }

    func relativePaths(under folder: String) -> [[String]] {
        let folderComponents = BundlePath(folder).components.map { $0.lowercased() }

        return paths.compactMap { path in
            let components = path.components
            let isInside = components.map { $0.lowercased() }.starts(with: folderComponents)
            return isInside ? Array(components.dropFirst(folderComponents.count)) : nil
        }
    }
}
