//
//  TouchEdgeTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchEdgeTests {
    @Test
    func initThenReadsASingleCenterControlAndSlotLists() throws {
        // Given / When
        let edge = try JSONFixtureDecoder().decode(
            TouchEdge.self,
            from: """
                {"center":{"type":"blank"},"leftCenter":[null,{"type":"blank"}],
                 "left":[{"type":"blank"}]}
                """
        )

        // Then
        let blank = TouchSlot.control(.init(kind: .blank))
        #expect(edge == .init(left: [blank], leftCenter: [.empty, blank], center: [blank]))
    }
}
