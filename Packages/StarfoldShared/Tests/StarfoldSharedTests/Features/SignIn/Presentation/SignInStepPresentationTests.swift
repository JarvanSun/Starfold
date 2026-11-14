//
//  SignInStepPresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import SwiftUI
import Testing

@testable import StarfoldShared

struct SignInStepPresentationTests {
    @Test(
        arguments: [
            (SignInStep.progress(.signedIn), SensoryFeedback?.some(.success)),
            (.failure("expired"), .error),
            (.progress(.signingIn), nil),
            (.preparing, nil),
        ]
    )
    func arrivalFeedbackThenMarksOnlyTheOutcome(step: SignInStep, feedback: SensoryFeedback?) {
        #expect(step.arrivalFeedback == feedback)
    }
}
