//
//  ConsolePowerControlPresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI
import Testing
import XboxKit

@testable import StarfoldShared

struct ConsolePowerControlPresentationTests {
    @Test(
        arguments: [
            (
                ConsolePowerControl.sending(.wakeUp), ConsolePowerControl.command(.turnOff),
                SensoryFeedback?.some(.success)
            ),
            (.sending(.turnOff), .command(.wakeUp), .success),
            (.sending(.wakeUp), .command(.wakeUp), nil),
            (.command(.wakeUp), .sending(.wakeUp), nil),
        ]
    )
    func feedbackThenMarksOnlyACommandThatTookEffect(
        previous: ConsolePowerControl,
        current: ConsolePowerControl,
        feedback: SensoryFeedback?
    ) {
        #expect(current.feedback(after: previous) == feedback)
    }
}
