//
//  TouchBundleFiles.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

struct TouchBundleFiles: Sendable {
    private let zip: ZipArchive
    private let entryNamesByKey: [String: String]
    private let paths: [BundlePath]
    private let manifestPath = "takxmanifest.json"

    init(archive: Data) throws(TouchBundleError) {
        do throws(ZipArchiveError) {
            zip = try ZipArchive(archive)
        } catch {
            throw .invalidArchive(error)
        }

        paths = zip.entryNames.map(BundlePath.init)
        entryNamesByKey = Dictionary(
            zip.entryNames.map { (BundlePath($0).key, $0) },
            uniquingKeysWith: { first, _ in first }
        )
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
        entryNamesByKey[BundlePath(path).key].flatMap { try? zip.contents(of: $0) }
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
