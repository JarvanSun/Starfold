//
//  ConsoleActivityDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

extension ConsoleActivity {
    nonisolated static var dummyLastPlayedHere: ConsoleActivity {
        .init(titleID: "T", name: "Last", imageURL: .dummyConsoleArtwork, kind: .lastPlayedHere)
    }
}
