//
//  ConsoleDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

extension Console {
    static var dummyLivingRoom: Console {
        .init(
            id: "F4001ABCDEF",
            name: "Living room Xbox",
            consoleType: "XboxSeriesX",
            powerState: .on
        )
    }
}
