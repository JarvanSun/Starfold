//
//  DataDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/14.
//

import Foundation

extension Data {
    static var hidingTheWheel: Data {
        Data(#"[{"op":"replace","path":"/showsWheel","value":false}]"#.utf8)
    }
}
