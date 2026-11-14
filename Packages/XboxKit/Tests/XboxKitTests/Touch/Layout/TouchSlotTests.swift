//
//  TouchSlotTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchSlotTests {
    @Test
    func initThenReadsEmptySingleAndClusteredSlots() throws {
        // Given / When
        let slots = try JSONFixtureDecoder().decode(
            [TouchSlot].self,
            from: #"[null,{"type":"blank"},[{"type":"blank"},null]]"#
        )

        // Then
        let blank = TouchControl(kind: .blank)
        #expect(slots == [.empty, .control(blank), .cluster([blank, nil])])
    }
}
