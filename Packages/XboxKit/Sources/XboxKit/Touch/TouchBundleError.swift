//
//  TouchBundleError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TouchBundleError: Error, Sendable, Equatable {
    case invalidArchive(ZipArchiveError)
    case missingManifest
    case invalidManifest(String)
    case invalidContext(String)
    case missingLayout(String)
    case invalidLayout(name: String, TouchLayoutError)
}
