//
//  StreamPhasePresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import SwiftUI
import Testing

@testable import StarfoldShared

struct StreamPhasePresentationTests {
    @Test(
        arguments: [
            (StreamPhase.streaming, SensoryFeedback?.some(.success)),
            (.ended(.hostEnded), .warning),
            (.ended(.connectionLost), .error),
            (.ended(.failed("4004")), .error),
            (.ended(.userStopped), nil),
            (.connecting, nil),
            (.provisioning, nil),
        ]
    )
    func arrivalFeedbackThenMatchesHowThePhaseWasReached(
        phase: StreamPhase,
        feedback: SensoryFeedback?
    ) {
        #expect(phase.arrivalFeedback == feedback)
    }
}
