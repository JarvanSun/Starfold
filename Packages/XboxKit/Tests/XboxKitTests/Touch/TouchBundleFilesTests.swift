//
//  TouchBundleFilesTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TouchBundleFilesTests {
    @Test
    func initWhenTheArchiveIsNotAZipThenThrowsInvalidArchive() {
        #expect(throws: TouchBundleError.invalidArchive(.missingEndOfCentralDirectory)) {
            try TouchBundleFiles(archive: Data("not a zip".utf8))
        }
    }

    @Test
    func contentsThenFindsFilesIgnoringCaseAndSeparators() throws {
        // Given
        let files = try makeFiles([#"Layouts\Neutral\Drive.json"#: "{}"])

        // When
        let contents = files.contents(at: "./layouts/neutral/drive.json")

        // Then
        #expect(contents == Data("{}".utf8))
    }

    @Test
    func relativePathsThenListsFilesInsideTheFolderWithTheirCase() throws {
        // Given
        let files = try makeFiles([
            "layouts/neutral/Drive.json": "{}",
            "layoutsExtra/a.json": "{}",
            "takxmanifest.json": "{}",
        ])

        // When
        let paths = files.relativePaths(under: "Layouts")

        // Then
        #expect(paths == [["neutral", "Drive.json"]])
    }

    @Test
    func manifestWhenItIsMissingThenThrows() throws {
        // Given
        let files = try makeFiles(["layouts/neutral/a.json": "{}"])

        // When / Then
        #expect(throws: TouchBundleError.missingManifest) { try files.manifest() }
    }

    @Test
    func manifestWhenItHasNoVersionThenThrowsInvalidManifest() throws {
        // Given
        let files = try makeFiles(["takxmanifest.json": #"{"layouts":"layouts"}"#])

        // When
        let error = #expect(throws: TouchBundleError.self) { try files.manifest() }

        // Then
        switch error {
        case .invalidManifest?: break
        default: Issue.record("Expected invalidManifest, got \(String(describing: error))")
        }
    }

    @Test
    func contextWhenTheFileIsMissingThenIsEmpty() throws {
        // Given
        let files = try makeFiles(["takxmanifest.json": "{}"])

        // When
        let context = try files.context(at: "context.json")

        // Then
        #expect(context == TouchContext())
    }

    @Test
    func contextThenReadsTheDocument() throws {
        // Given
        let files = try makeFiles(["context.json": .dummyLayeredContext])

        // When
        let context = try files.context(at: "context.json")

        // Then
        #expect(context.state["shieldImage"] == .string("ShieldIdle"))
    }

    @Test
    func contextWhenTheDocumentIsNotAnObjectThenThrows() throws {
        // Given
        let files = try makeFiles(["context.json": "[]"])

        // When / Then
        #expect(throws: TouchBundleError.invalidContext("The context is not a JSON object")) {
            try files.context(at: "context.json")
        }
    }
}

private extension TouchBundleFilesTests {
    func makeFiles(_ files: [String: String]) throws -> TouchBundleFiles {
        let entries = files.sorted { $0.key < $1.key }.map { path, text in
            ZipArchiveBuilder.Entry(name: path, contents: Data(text.utf8))
        }
        return try TouchBundleFiles(archive: ZipArchiveBuilder().archive(entries))
    }
}
