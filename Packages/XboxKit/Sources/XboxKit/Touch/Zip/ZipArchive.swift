//
//  ZipArchive.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Compression
import Foundation

struct ZipArchive: Sendable {
    let entryNames: [String]

    private let bytes: ZipBytes
    private let entries: [String: ZipEntry]
    private let maximumEntrySize = 64 * 1024 * 1024

    init(_ archive: Data) throws(ZipArchiveError) {
        let bytes = ZipBytes(contents: Array(archive))
        let entries = try bytes.centralDirectoryEntries()
            .filter { !$0.name.hasSuffix("/") }

        self.bytes = bytes
        self.entryNames = entries.map(\.name)
        self.entries = Dictionary(entries.map { ($0.name, $0) }) { first, _ in first }
    }

    func contents(of name: String) throws(ZipArchiveError) -> Data {
        guard let entry = entries[name] else { throw .missingEntry(name) }
        guard !entry.isEncrypted else { throw .encryptedEntry(name) }
        guard entry.size <= maximumEntrySize else { throw .entryTooLarge(name) }

        let stored = try bytes.storedContents(of: entry)
        let contents = try expanded(stored, of: entry)
        guard CRC32().checksum(of: contents) == entry.checksum else {
            throw .checksumMismatch(name)
        }

        return Data(contents)
    }

    private func expanded(
        _ stored: ArraySlice<UInt8>,
        of entry: ZipEntry
    ) throws(ZipArchiveError) -> [UInt8] {
        switch (entry.method, entry.size) {
        case (.stored, entry.compressedSize): return Array(stored)
        case (.stored, _): throw .corruptEntry(entry.name)
        case (.deflated, 0): return []
        case (.deflated, _): return try inflated(stored, of: entry)
        case (.other(let method), _):
            throw .unsupportedCompression(method: method, entry: entry.name)
        }
    }

    private func inflated(
        _ compressed: ArraySlice<UInt8>,
        of entry: ZipEntry
    ) throws(ZipArchiveError) -> [UInt8] {
        var output = [UInt8](repeating: 0, count: entry.size + 1)
        let writtenCount = compressed.withUnsafeBufferPointer { source in
            output.withUnsafeMutableBufferPointer { destination in
                guard let sourceStart = source.baseAddress,
                    let destinationStart = destination.baseAddress
                else { return 0 }

                return compression_decode_buffer(
                    destinationStart,
                    destination.count,
                    sourceStart,
                    source.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }
        guard writtenCount == entry.size else { throw .corruptEntry(entry.name) }

        return Array(output.prefix(entry.size))
    }
}

private struct ZipEntry: Sendable {
    enum Method: Sendable, Equatable {
        case stored
        case deflated
        case other(Int)

        init(code: UInt16) {
            let storedCode: UInt16 = 0
            let deflatedCode: UInt16 = 8

            self =
                switch code {
                case storedCode: .stored
                case deflatedCode: .deflated
                default: .other(Int(code))
                }
        }
    }

    let name: String
    let method: Method
    let isEncrypted: Bool
    let checksum: UInt32
    let compressedSize: Int
    let size: Int
    let localHeaderOffset: Int
}

private struct ZipBytes: Sendable {
    enum EndOfCentralDirectoryField: Int {
        case diskNumber = 4
        case directoryDiskNumber = 6
        case entryCount = 10
        case directoryOffset = 16
    }

    enum CentralDirectoryField: Int {
        case flags = 8
        case method = 10
        case checksum = 16
        case compressedSize = 20
        case size = 24
        case nameLength = 28
        case extraLength = 30
        case commentLength = 32
        case localHeaderOffset = 42
    }

    enum LocalHeaderField: Int {
        case nameLength = 26
        case extraLength = 28
    }

    let contents: [UInt8]

    private let endOfCentralDirectorySignature: UInt32 = 0x0605_4B50
    private let zip64LocatorSignature: UInt32 = 0x0706_4B50
    private let centralDirectorySignature: UInt32 = 0x0201_4B50
    private let localHeaderSignature: UInt32 = 0x0403_4B50
    private let endOfCentralDirectoryLength = 22
    private let zip64LocatorLength = 20
    private let centralDirectoryHeaderLength = 46
    private let localHeaderLength = 30

    func centralDirectoryEntries() throws(ZipArchiveError) -> [ZipEntry] {
        let end = try endOfCentralDirectoryOffset()
        try rejectUnsupportedLayout(endingAt: end)

        let entryCount = try uint16(at: end + EndOfCentralDirectoryField.entryCount.rawValue)
        var offset = Int(try uint32(at: end + EndOfCentralDirectoryField.directoryOffset.rawValue))
        var entries: [ZipEntry] = []

        for _ in 0..<entryCount {
            let (entry, length) = try centralDirectoryEntry(at: offset)
            entries.append(entry)
            offset += length
        }

        return entries
    }

    private func endOfCentralDirectoryOffset() throws(ZipArchiveError) -> Int {
        let latest = contents.count - endOfCentralDirectoryLength
        let earliest = max(0, latest - Int(UInt16.max))
        guard latest >= 0 else { throw .missingEndOfCentralDirectory }

        let candidate = stride(from: latest, through: earliest, by: -1).first { offset in
            (try? uint32(at: offset)) == endOfCentralDirectorySignature
        }
        guard let candidate else { throw .missingEndOfCentralDirectory }

        return candidate
    }

    private func rejectUnsupportedLayout(endingAt end: Int) throws(ZipArchiveError) {
        let locatorSignature = try? uint32(at: end - zip64LocatorLength)
        let entryCount = try uint16(at: end + EndOfCentralDirectoryField.entryCount.rawValue)
        let directoryOffset = try uint32(
            at: end + EndOfCentralDirectoryField.directoryOffset.rawValue
        )
        let isZip64 =
            locatorSignature == zip64LocatorSignature || entryCount == UInt16.max
            || directoryOffset == UInt32.max
        guard !isZip64 else { throw .zip64Unsupported }

        let diskNumber = try uint16(at: end + EndOfCentralDirectoryField.diskNumber.rawValue)
        let directoryDiskNumber = try uint16(
            at: end + EndOfCentralDirectoryField.directoryDiskNumber.rawValue
        )
        guard diskNumber == 0, directoryDiskNumber == 0 else { throw .spannedArchiveUnsupported }
    }

    private func centralDirectoryEntry(
        at offset: Int
    ) throws(ZipArchiveError) -> (entry: ZipEntry, length: Int) {
        guard try uint32(at: offset) == centralDirectorySignature else {
            throw .corruptCentralDirectory
        }

        let compressedSize = try uint32(field: .compressedSize, of: offset)
        let size = try uint32(field: .size, of: offset)
        let localHeaderOffset = try uint32(field: .localHeaderOffset, of: offset)
        let isZip64 = [compressedSize, size, localHeaderOffset].contains(UInt32.max)
        guard !isZip64 else { throw .zip64Unsupported }

        let encryptedFlag: UInt16 = 1
        let nameLength = Int(try uint16(field: .nameLength, of: offset))
        let extraLength = Int(try uint16(field: .extraLength, of: offset))
        let commentLength = Int(try uint16(field: .commentLength, of: offset))
        let name = try slice(from: offset + centralDirectoryHeaderLength, count: nameLength)
        let entry = ZipEntry(
            name: String(decoding: name, as: UTF8.self),
            method: .init(code: try uint16(field: .method, of: offset)),
            isEncrypted: try uint16(field: .flags, of: offset) & encryptedFlag != 0,
            checksum: try uint32(field: .checksum, of: offset),
            compressedSize: Int(compressedSize),
            size: Int(size),
            localHeaderOffset: Int(localHeaderOffset)
        )
        return (entry, centralDirectoryHeaderLength + nameLength + extraLength + commentLength)
    }

    private func slice(from offset: Int, count: Int) throws(ZipArchiveError) -> ArraySlice<UInt8> {
        guard offset >= 0, count >= 0, offset <= contents.count - count else { throw .truncated }

        return contents[offset..<(offset + count)]
    }

    private func uint16(field: CentralDirectoryField, of header: Int) throws(ZipArchiveError)
        -> UInt16
    {
        try uint16(at: header + field.rawValue)
    }

    private func uint32(field: CentralDirectoryField, of header: Int) throws(ZipArchiveError)
        -> UInt32
    {
        try uint32(at: header + field.rawValue)
    }

    func storedContents(of entry: ZipEntry) throws(ZipArchiveError) -> ArraySlice<UInt8> {
        let header = entry.localHeaderOffset
        guard try uint32(at: header) == localHeaderSignature else {
            throw .corruptEntry(entry.name)
        }

        let nameLength = Int(try uint16(at: header + LocalHeaderField.nameLength.rawValue))
        let extraLength = Int(try uint16(at: header + LocalHeaderField.extraLength.rawValue))
        let start = header + localHeaderLength + nameLength + extraLength
        return try slice(from: start, count: entry.compressedSize)
    }

    private func uint16(at offset: Int) throws(ZipArchiveError) -> UInt16 {
        let bytes = try slice(from: offset, count: MemoryLayout<UInt16>.size)
        return bytes.reversed().reduce(0) { ($0 << UInt8.bitWidth) | UInt16($1) }
    }

    private func uint32(at offset: Int) throws(ZipArchiveError) -> UInt32 {
        let bytes = try slice(from: offset, count: MemoryLayout<UInt32>.size)
        return bytes.reversed().reduce(0) { ($0 << UInt8.bitWidth) | UInt32($1) }
    }
}
