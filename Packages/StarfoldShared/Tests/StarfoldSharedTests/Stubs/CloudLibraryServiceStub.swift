//
//  CloudLibraryServiceStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import StarfoldShared

final class CloudLibraryServiceStub: CloudLibraryService {
    var content: Result<CloudLibrary, Error> = .success(.dummyEmpty)
    var isHanging = false

    func library() async throws -> CloudLibrary {
        if isHanging {
            try await Task.sleep(for: .seconds(3600))
        }

        return try content.get()
    }
}
