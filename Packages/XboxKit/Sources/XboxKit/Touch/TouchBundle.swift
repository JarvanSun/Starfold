//
//  TouchBundle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

public struct TouchBundle: Sendable {
    public let manifest: TouchBundleManifest
    public let context: TouchContext

    private let files: TouchBundleFiles
    private let neutralFolder = "neutral"
    private let layoutExtension = ".json"

    public var layoutNames: [String] {
        let names = files.relativePaths(under: manifest.layoutsFolder).compactMap { components in
            let file = components.last ?? ""
            let isLayout = components.count == 2 && file.lowercased().hasSuffix(layoutExtension)
            return isLayout ? String(file.dropLast(layoutExtension.count)) : nil
        }
        var seen: Set<String> = []
        return names.filter { seen.insert($0.lowercased()).inserted }.sorted()
    }

    public init(archive: Data) throws(TouchBundleError) {
        let files = try TouchBundleFiles(archive: archive)
        let manifest = try files.manifest()

        self.files = files
        self.manifest = manifest
        self.context = try files.context(at: manifest.contextPath)
    }

    public func layout(
        named name: String,
        locale: String,
        context: TouchContext
    ) throws(TouchBundleError) -> TouchLayout {
        let json = folders(for: locale).lazy.compactMap { folder in
            files.contents(at: "\(manifest.layoutsFolder)/\(folder)/\(name)\(layoutExtension)")
        }.first
        guard let json else { throw .missingLayout(name) }

        do throws(TouchLayoutError) {
            return try TouchLayout(json: json, context: context)
        } catch {
            throw .invalidLayout(name: name, error)
        }
    }

    private func folders(for locale: String) -> [String] {
        let identifier = locale.replacing("_", with: "-").lowercased()
        let language = identifier.split(separator: "-").first.map(String.init) ?? identifier
        var seen: Set<String> = []
        return [identifier, language, neutralFolder].filter { seen.insert($0).inserted }
    }
}
