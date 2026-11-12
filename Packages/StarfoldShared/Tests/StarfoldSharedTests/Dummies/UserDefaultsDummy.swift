//
//  UserDefaultsDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension UserDefaults {
    static var dummyEmpty: UserDefaults {
        .init(suiteName: dummySuiteName())!
    }

    static func dummySuiteName() -> String {
        "StarfoldTests.\(UUID().uuidString)"
    }
}
