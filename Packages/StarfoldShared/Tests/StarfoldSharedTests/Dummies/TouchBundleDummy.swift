//
//  TouchBundleDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/14.
//

import Foundation
import XboxKit

extension TouchBundle {
    static func dummy() throws -> TouchBundle {
        let files = [
            "takxmanifest.json":
                #"{"defaultLayout":"main","layouts":"layouts","version":"1.0.0.0"}"#,
            "context.json": #"{"state":{"showsWheel":true}}"#,
            "layouts/neutral/main.json":
                #"{"content":{"right":{"inner":[{"type":"steeringWheel","visible":{"$ref":"../../context.json#/state/showsWheel"}}]}}}"#,
        ]
        let entries = files.sorted { $0.key < $1.key }
            .map { path, text in ZipArchiveBuilder.Entry(name: path, contents: Data(text.utf8)) }
        return try TouchBundle(archive: ZipArchiveBuilder().archive(entries))
    }
}
