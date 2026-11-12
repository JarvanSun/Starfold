//
//  ConsoleActivityDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension ConsoleActivity {
    static var dummyDiablo: ConsoleActivity {
        .init(
            titleID: "200",
            name: "Diablo IV",
            imageURL: URL(string: "https://img/d4"),
            kind: .playingNow
        )
    }
}
