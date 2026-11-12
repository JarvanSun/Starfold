//
//  DialogButton.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct DialogButton: Equatable, Identifiable {
    public let index: Int
    public let title: String
    public let role: DialogButtonRole

    public var id: Int {
        index
    }
}
