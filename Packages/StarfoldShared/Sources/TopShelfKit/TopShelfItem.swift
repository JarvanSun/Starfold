//
//  TopShelfItem.swift
//  TopShelfKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public nonisolated struct TopShelfItem: Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var imageURL: URL?

    public init(id: String, title: String, imageURL: URL?) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }
}
