//
//  LoadState.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
