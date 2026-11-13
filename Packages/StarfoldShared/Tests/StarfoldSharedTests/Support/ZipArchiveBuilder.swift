//
//  ZipArchiveBuilder.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Compression
import Foundation

@testable import XboxKit

struct ZipArchiveBuilder {
    struct Entry {
        enum Method: UInt16 {
            case stored = 0
            case deflated = 8
            case bzip2 = 12
        }

        var name: String
        var contents: Data
        var method: Method = .deflated
        var isEncrypted = false
    }

    func archive(_ entries: [Entry]) -> Data {
        var archive = Data()
        var directory = Data()

        for entry in entries {
            let name = Data(entry.name.utf8)
            let stored = storedContents(of: entry)
            let checksum = CRC32().checksum(of: entry.contents)
            let flags: UInt16 = entry.isEncrypted ? 1 : 0
            let offset = UInt32(archive.count)

            archive +=
                uint32(0x0403_4B50) + uint16(20) + uint16(flags) + uint16(entry.method.rawValue)
            archive += uint16(0) + uint16(0) + uint32(checksum)
            archive += uint32(UInt32(stored.count)) + uint32(UInt32(entry.contents.count))
            archive += uint16(UInt16(name.count)) + uint16(0) + name + stored

            directory += uint32(0x0201_4B50) + uint16(20) + uint16(20) + uint16(flags)
            directory += uint16(entry.method.rawValue) + uint16(0) + uint16(0) + uint32(checksum)
            directory += uint32(UInt32(stored.count)) + uint32(UInt32(entry.contents.count))
            directory += uint16(UInt16(name.count)) + uint16(0) + uint16(0) + uint16(0)
            directory += uint16(0) + uint32(0) + uint32(offset) + name
        }

        let directoryOffset = UInt32(archive.count)
        archive += directory
        archive += uint32(0x0605_4B50) + uint16(0) + uint16(0)
        archive += uint16(UInt16(entries.count)) + uint16(UInt16(entries.count))
        archive += uint32(UInt32(directory.count)) + uint32(directoryOffset) + uint16(0)
        return archive
    }

    private func storedContents(of entry: Entry) -> Data {
        switch entry.method {
        case .deflated: deflated(entry.contents)
        case .stored, .bzip2: entry.contents
        }
    }

    private func deflated(_ contents: Data) -> Data {
        let source = [UInt8](contents)
        var destination = [UInt8](repeating: 0, count: source.count + 64)
        let count = compression_encode_buffer(
            &destination,
            destination.count,
            source,
            source.count,
            nil,
            COMPRESSION_ZLIB
        )
        return Data(destination.prefix(count))
    }

    private func uint16(_ number: UInt16) -> Data {
        withUnsafeBytes(of: number.littleEndian) { Data($0) }
    }

    private func uint32(_ number: UInt32) -> Data {
        withUnsafeBytes(of: number.littleEndian) { Data($0) }
    }
}
