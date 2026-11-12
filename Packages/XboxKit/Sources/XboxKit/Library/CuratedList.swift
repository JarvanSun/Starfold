//
//  CuratedList.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct CuratedList: Sendable, Hashable {
    public var id: String
    public var title: String
    public var productIDs: [String]

    public init(id: String, title: String, productIDs: [String]) {
        self.id = id
        self.title = title
        self.productIDs = productIDs
    }
}
