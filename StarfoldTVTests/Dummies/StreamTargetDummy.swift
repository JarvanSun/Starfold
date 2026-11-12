//
//  StreamTargetDummy.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

extension StreamTarget {
    nonisolated static var dummyLivingRoom: StreamTarget {
        .console(id: "1", name: "Xbox")
    }

    nonisolated static func dummy(named name: String) -> StreamTarget {
        .console(id: name, name: name)
    }
}
