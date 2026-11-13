//
//  BundlePath.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct BundlePath: Hashable {
    let normalized: String

    var key: String {
        normalized.lowercased()
    }

    var components: [String] {
        normalized.split(separator: "/").map(String.init)
    }

    init(_ path: String) {
        let currentFolder = "."
        normalized = path.replacing("\\", with: "/")
            .split(separator: "/")
            .filter { $0 != currentFolder }
            .joined(separator: "/")
    }
}
