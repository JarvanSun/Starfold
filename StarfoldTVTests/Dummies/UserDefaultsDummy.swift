//
//  UserDefaultsDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension UserDefaults {
    static var dummyEmpty: UserDefaults {
        .init(suiteName: "com.jarvansun.sunbox.tests.\(UUID().uuidString)")!
    }
}
