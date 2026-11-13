//
//  TouchBundleManifestTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TouchBundleManifestTests {
    @Test
    func initThenReadsVersionDefaultLayoutAndFolders() throws {
        // Given
        let json = """
            {"defaultLayout":"custom-assets","layouts":"./Layouts/","assets":"art",
             "context":"./state/context.json","version":"1.0.0.0","versionName":"Launch"}
            """

        // When
        let manifest = try JSONDecoder().decode(TouchBundleManifest.self, from: Data(json.utf8))

        // Then
        #expect(manifest.version == "1.0.0.0")
        #expect(manifest.versionName == "Launch")
        #expect(manifest.defaultLayoutName == "custom-assets")
        #expect(manifest.layoutsFolder == "Layouts")
        #expect(manifest.assetsFolder == "art")
        #expect(manifest.contextPath == "state/context.json")
    }

    @Test
    func initWhenFoldersAreMissingOrNotTextThenUsesTheStandardOnes() throws {
        // Given
        let json = #"{"version":"1.1.0.0","context":{"path":"./context.json"}}"#

        // When
        let manifest = try JSONDecoder().decode(TouchBundleManifest.self, from: Data(json.utf8))

        // Then
        #expect(manifest.defaultLayoutName == nil)
        #expect(manifest.layoutsFolder == "layouts")
        #expect(manifest.assetsFolder == "assets")
        #expect(manifest.contextPath == "context.json")
    }
}
