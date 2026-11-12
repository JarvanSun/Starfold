//
//  CloudGame.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct CloudGame: Codable, Sendable, Hashable, Identifiable {
    public var title: CloudTitle
    public var product: CatalogProduct?

    public var id: String {
        title.id
    }

    public var name: String {
        product?.title ?? title.id
    }

    public init(title: CloudTitle, product: CatalogProduct?) {
        self.title = title
        self.product = product
    }
}
