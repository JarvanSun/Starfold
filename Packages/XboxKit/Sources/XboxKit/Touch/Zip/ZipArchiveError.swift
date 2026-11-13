//
//  ZipArchiveError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum ZipArchiveError: Error, Sendable, Equatable {
    case missingEndOfCentralDirectory
    case truncated
    case corruptCentralDirectory
    case zip64Unsupported
    case spannedArchiveUnsupported
    case missingEntry(String)
    case encryptedEntry(String)
    case unsupportedCompression(method: Int, entry: String)
    case entryTooLarge(String)
    case corruptEntry(String)
    case checksumMismatch(String)
}
