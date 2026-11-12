//
//  CandidateGathering.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import XboxKit

struct CandidateGathering {
    private(set) var candidates: [LocalICECandidate] = []
    private(set) var isComplete = false

    private var lastCandidateAt: ContinuousClock.Instant?

    mutating func add(_ candidate: LocalICECandidate, at instant: ContinuousClock.Instant) {
        candidates.append(candidate)

        lastCandidateAt = instant
    }

    mutating func complete() {
        isComplete = true
    }

    func isSettled(at instant: ContinuousClock.Instant, quietPeriod: Duration) -> Bool {
        switch (isComplete, lastCandidateAt) {
        case (true, _):
            true
        case (false, let lastCandidateAt?):
            hasPublicCandidate && instant - lastCandidateAt > quietPeriod
        case (false, nil):
            false
        }
    }
}

private extension CandidateGathering {
    var hasPublicCandidate: Bool {
        candidates.contains { $0.candidate.contains(" typ srflx") }
    }
}
