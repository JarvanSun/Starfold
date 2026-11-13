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

    public func asset(named name: String, scale: Double, locale: String) -> TouchAsset? {
        let assetFiles = files.relativePaths(under: manifest.assetsFolder)
            .compactMap(AssetFile.init(components:))

        for folder in folders(for: locale) {
            let matching = assetFiles.filter { $0.folder == folder && $0.name == name.lowercased() }
            let atLeastRequested = matching.filter { $0.scale >= scale }.min { $0.scale < $1.scale }
            let best = atLeastRequested ?? matching.max { $0.scale < $1.scale }
            let path = best.map { ([manifest.assetsFolder] + $0.components).joined(separator: "/") }
            if let best, let png = path.flatMap(files.contents(at:)) {
                return .init(png: png, scale: best.scale)
            }
        }

        return nil
    }

    private func folders(for locale: String) -> [String] {
        let identifier = locale.replacing("_", with: "-").lowercased()
        let language = identifier.split(separator: "-").first.map(String.init) ?? identifier
        var seen: Set<String> = []
        return [identifier, language, neutralFolder].filter { seen.insert($0).inserted }
    }
}

private struct AssetFile {
    let components: [String]
    let folder: String
    let scale: Double
    let name: String

    init?(components: [String]) {
        let scalePrefix = "@"
        let scaleSuffix = "x"
        let assetExtension = ".png"
        guard components.count == 3 else { return nil }

        let scaleFolder = components[1].lowercased()
        let file = components[2].lowercased()
        let isScaleFolder = scaleFolder.hasPrefix(scalePrefix) && scaleFolder.hasSuffix(scaleSuffix)
        let scale = Double(scaleFolder.dropFirst(scalePrefix.count).dropLast(scaleSuffix.count))
        guard isScaleFolder, file.hasSuffix(assetExtension), let scale else { return nil }

        self.components = components
        self.folder = components[0].lowercased()
        self.scale = scale
        self.name = String(file.dropLast(assetExtension.count))
    }
}
