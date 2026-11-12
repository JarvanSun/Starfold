//
//  CloudLibraryService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public protocol CloudLibraryService {
    func library() async throws -> CloudLibrary
}
