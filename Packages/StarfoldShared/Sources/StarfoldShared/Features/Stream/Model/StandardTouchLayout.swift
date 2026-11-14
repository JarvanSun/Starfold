//
//  StandardTouchLayout.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import XboxKit

struct StandardTouchLayout {
    let layout: TouchLayout

    init() {
        let resource = Bundle.module.url(forResource: "StandardTouchLayout", withExtension: "json")
        let json = resource.flatMap { try? Data(contentsOf: $0) } ?? Data()
        layout = (try? TouchLayout(json: json, context: TouchContext())) ?? .init(base: .init())
    }
}
