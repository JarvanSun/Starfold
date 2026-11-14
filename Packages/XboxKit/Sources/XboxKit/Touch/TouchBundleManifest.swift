//
//  TouchBundleManifest.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchBundleManifest: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case version
        case versionName
        case defaultLayoutName = "defaultLayout"
        case layoutsFolder = "layouts"
        case contextPath = "context"
    }

    public let version: String
    public let versionName: String?
    public let defaultLayoutName: String?

    let layoutsFolder: String
    let contextPath: String

    public init(version: String, versionName: String? = nil, defaultLayoutName: String? = nil) {
        self.version = version
        self.versionName = versionName
        self.defaultLayoutName = defaultLayoutName
        self.layoutsFolder = "layouts"
        self.contextPath = "context.json"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = TouchBundleManifest(version: "")
        let path = { (key: CodingKeys, fallback: String) -> String in
            let declared = try? container.decodeIfPresent(String.self, forKey: key)
            return BundlePath(declared ?? fallback).normalized
        }

        version = try container.decode(String.self, forKey: .version)
        versionName = try container.decodeIfPresent(String.self, forKey: .versionName)
        defaultLayoutName = try container.decodeIfPresent(String.self, forKey: .defaultLayoutName)
        layoutsFolder = path(.layoutsFolder, defaults.layoutsFolder)
        contextPath = path(.contextPath, defaults.contextPath)
    }
}
