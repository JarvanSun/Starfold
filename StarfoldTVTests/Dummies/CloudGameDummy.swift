//
//  CloudGameDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

extension CloudGame {
    static func dummyRecentGames(count: Int) -> [CloudGame] {
        (1...count).map { number in
            .init(
                title: .init(
                    id: "GAME\(number)",
                    productID: "GAME\(number)",
                    hasEntitlement: true,
                    isFreeInStore: false,
                    supportedInputTypes: ["Controller"]
                ),
                product: nil
            )
        }
    }
}
