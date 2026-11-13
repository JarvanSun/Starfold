//
//  ZipArchiveTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct ZipArchiveTests {
    @Test
    func contentsThenReadsStoredAndDeflatedEntries() throws {
        // Given
        let text = Data(String(repeating: "touch layout ", count: 40).utf8)
        let archive = try ZipArchive(
            ZipArchiveBuilder().archive([
                .init(name: "stored.txt", contents: Data("plain".utf8), method: .stored),
                .init(name: "deflated.txt", contents: text, method: .deflated),
                .init(name: "empty.txt", contents: Data(), method: .deflated),
            ])
        )

        // When
        let stored = try archive.contents(of: "stored.txt")
        let deflated = try archive.contents(of: "deflated.txt")
        let empty = try archive.contents(of: "empty.txt")

        // Then
        #expect(archive.entryNames == ["stored.txt", "deflated.txt", "empty.txt"])
        #expect(stored == Data("plain".utf8))
        #expect(deflated == text)
        #expect(empty.isEmpty)
    }

    @Test
    func initThenSkipsFolderEntries() throws {
        // Given
        let built = ZipArchiveBuilder().archive([
            .init(name: "layouts/", contents: Data(), method: .stored),
            .init(name: "layouts/neutral/a.json", contents: Data("{}".utf8)),
        ])

        // When
        let archive = try ZipArchive(built)

        // Then
        #expect(archive.entryNames == ["layouts/neutral/a.json"])
    }

    @Test
    func contentsWhenTheMicrosoftSampleBundleIsReadThenEveryChecksumMatches() throws {
        // Given
        let archive = try ZipArchive(.dummySampleLayoutsBundle)

        // When
        let manifest = try archive.contents(of: "takxmanifest.json")

        // Then
        #expect(archive.entryNames.count == 7)
        #expect(String(decoding: manifest, as: UTF8.self).contains(#""defaultLayout""#))
        for name in archive.entryNames {
            #expect(throws: Never.self) { try archive.contents(of: name) }
        }
    }

    @Test
    func contentsWhenStoredBytesAreCorruptedThenThrowsChecksumMismatch() throws {
        // Given
        var built = ZipArchiveBuilder().archive([
            .init(name: "a.txt", contents: Data("abcdef".utf8), method: .stored)
        ])
        let contentStart = try #require(built.firstRange(of: Data("abcdef".utf8))).lowerBound
        built[contentStart] = UInt8(ascii: "z")
        let archive = try ZipArchive(built)

        // When / Then
        #expect(throws: ZipArchiveError.checksumMismatch("a.txt")) {
            try archive.contents(of: "a.txt")
        }
    }

    @Test
    func contentsWhenDeflatedBytesAreCorruptedThenThrows() throws {
        // Given
        let text = Data(String(repeating: "abc", count: 100).utf8)
        var built = ZipArchiveBuilder().archive([.init(name: "a.txt", contents: text)])
        let headerLength = 30 + "a.txt".utf8.count
        built[headerLength] ^= 0xFF
        built[headerLength + 1] ^= 0xFF
        let archive = try ZipArchive(built)

        // When / Then
        #expect(throws: ZipArchiveError.self) { try archive.contents(of: "a.txt") }
    }

    @Test(arguments: [0, 10, 40])
    func initWhenTheArchiveIsTruncatedThenThrows(keptByteCount: Int) {
        // Given
        let built = ZipArchiveBuilder().archive([.init(name: "a.txt", contents: Data("abc".utf8))])

        // When / Then
        #expect(throws: ZipArchiveError.missingEndOfCentralDirectory) {
            try ZipArchive(built.prefix(keptByteCount))
        }
    }

    @Test
    func initWhenTheCentralDirectoryIsMissingThenThrowsTruncated() {
        // Given
        let built = ZipArchiveBuilder().archive([.init(name: "a.txt", contents: Data("abc".utf8))])
        let endRecordLength = 22

        // When / Then
        #expect(throws: ZipArchiveError.truncated) {
            try ZipArchive(Data(built.suffix(endRecordLength)))
        }
    }

    @Test
    func contentsWhenTheEntryIsEncryptedThenThrows() throws {
        // Given
        let archive = try ZipArchive(
            ZipArchiveBuilder().archive([
                .init(name: "secret.txt", contents: Data("x".utf8), isEncrypted: true)
            ])
        )

        // When / Then
        #expect(throws: ZipArchiveError.encryptedEntry("secret.txt")) {
            try archive.contents(of: "secret.txt")
        }
    }

    @Test
    func contentsWhenTheMethodIsUnsupportedThenThrows() throws {
        // Given
        let archive = try ZipArchive(
            ZipArchiveBuilder().archive([
                .init(name: "a.bz2", contents: Data("x".utf8), method: .bzip2)
            ])
        )

        // When / Then
        #expect(throws: ZipArchiveError.unsupportedCompression(method: 12, entry: "a.bz2")) {
            try archive.contents(of: "a.bz2")
        }
    }

    @Test
    func initWhenTheArchiveIsZip64ThenThrows() {
        // Given
        var built = ZipArchiveBuilder().archive([.init(name: "a.txt", contents: Data("a".utf8))])
        let entryCountOffset = built.count - 22 + 10
        built[entryCountOffset] = 0xFF
        built[entryCountOffset + 1] = 0xFF

        // When / Then
        #expect(throws: ZipArchiveError.zip64Unsupported) { try ZipArchive(built) }
    }

    @Test
    func contentsWhenTheEntryIsMissingThenThrows() throws {
        // Given
        let archive = try ZipArchive(ZipArchiveBuilder().archive([]))

        // When / Then
        #expect(throws: ZipArchiveError.missingEntry("a.txt")) { try archive.contents(of: "a.txt") }
    }
}
