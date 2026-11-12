//
//  StreamTargetDummy.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit

extension StreamTarget {
    static var dummyConsole: StreamTarget {
        .console(id: "F4001A2B3C4D5E6F", name: "Living room")
    }

    static var dummyCloudGame: StreamTarget {
        .cloud(titleID: "STARFIELDRUN", name: "Starfield Run")
    }
}
