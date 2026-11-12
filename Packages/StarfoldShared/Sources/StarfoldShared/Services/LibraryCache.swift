//
//  LibraryCache.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/29.
//

import Foundation
import XboxKit

public struct LibraryCache {
    private let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    func homeSnapshot(for xuid: String) -> HomeSnapshot? {
        load(from: snapshotFile(named: "home", for: xuid))
    }

    func save(_ snapshot: HomeSnapshot, for xuid: String) {
        save(snapshot, to: snapshotFile(named: "home", for: xuid))
    }

    func librarySnapshot(for xuid: String) -> LibrarySnapshot? {
        load(from: snapshotFile(named: "library", for: xuid))
    }

    func save(_ snapshot: LibrarySnapshot, for xuid: String) {
        save(snapshot, to: snapshotFile(named: "library", for: xuid))
    }

    func saveLastFrame(_ jpeg: Data, console consoleID: String, for xuid: String) {
        let folder = framesDirectory(for: xuid)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try? jpeg.write(to: folder.appending(path: frameFileName(for: consoleID)), options: .atomic)
    }

    func lastFrames(for xuid: String) -> [String: Data] {
        var frames: [String: Data] = [:]

        for file in frameFiles(for: xuid) {
            guard
                let consoleID = file.deletingPathExtension().lastPathComponent
                    .removingPercentEncoding,
                let data = try? Data(contentsOf: file)
            else {
                continue
            }

            frames[consoleID] = data
        }

        return frames
    }

    func removeLastFrames(for xuid: String) {
        try? FileManager.default.removeItem(at: framesDirectory(for: xuid))
    }
}

private extension LibraryCache {
    var frameFileExtension: String {
        "jpg"
    }

    func snapshotFile(named name: String, for xuid: String) -> URL {
        directory.appending(path: "\(name)-\(xuid).json")
    }

    func load<Snapshot: Decodable>(from file: URL) -> Snapshot? {
        guard let data = try? Data(contentsOf: file) else { return nil }

        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }

    func save(_ snapshot: some Encodable, to file: URL) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        guard let data = try? JSONEncoder().encode(snapshot) else { return }

        try? data.write(to: file, options: .atomic)
    }

    func framesDirectory(for xuid: String) -> URL {
        directory
            .appending(path: "LastFrames", directoryHint: .isDirectory)
            .appending(path: xuid, directoryHint: .isDirectory)
    }

    func frameFileName(for consoleID: String) -> String {
        let name =
            consoleID.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? consoleID
        return name + "." + frameFileExtension
    }

    func frameFiles(for xuid: String) -> [URL] {
        let files =
            (try? FileManager.default.contentsOfDirectory(
                at: framesDirectory(for: xuid),
                includingPropertiesForKeys: nil
            )) ?? []
        return files.filter { $0.pathExtension == frameFileExtension }
    }
}
