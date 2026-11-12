//
//  LibraryPlaceholder.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum LibraryPlaceholder: Equatable {
    case loading
    case failed(String)
    case unavailable
    case noResults
}
