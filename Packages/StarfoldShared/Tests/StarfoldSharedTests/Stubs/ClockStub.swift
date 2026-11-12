//
//  ClockStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Synchronization

final class ClockStub: Clock {
    struct Instant: InstantProtocol {
        let offset: Duration

        func advanced(by duration: Duration) -> Instant {
            .init(offset: offset + duration)
        }

        func duration(to other: Instant) -> Duration {
            other.offset - offset
        }

        static func < (lhs: Instant, rhs: Instant) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    struct Sleeper {
        let id: Int
        let deadline: Instant
        let continuation: CheckedContinuation<Void, Error>
    }

    struct State {
        var now = Instant(offset: .zero)
        var lastSleeperID = 0
        var sleepers: [Sleeper] = []
        var cancelledSleeperIDs: Set<Int> = []
    }

    private let state = Mutex(State())

    var now: Instant {
        state.withLock { $0.now }
    }

    var minimumResolution: Duration {
        .zero
    }

    var sleeperCount: Int {
        state.withLock { $0.sleepers.count }
    }

    func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        let id = state.withLock { state in
            state.lastSleeperID += 1
            return state.lastSleeperID
        }

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                wait(.init(id: id, deadline: deadline, continuation: continuation))
            }
        } onCancel: {
            cancelSleeper(id: id)
        }
    }

    func advance(by duration: Duration) {
        let dueSleepers = state.withLock { state in
            state.now = state.now.advanced(by: duration)
            let now = state.now
            let due = state.sleepers.filter { $0.deadline <= now }
            state.sleepers.removeAll { $0.deadline <= now }
            return due
        }

        for sleeper in dueSleepers {
            sleeper.continuation.resume()
        }
    }
}

private extension ClockStub {
    enum Wake {
        case later
        case now
        case cancelled
    }

    func wait(_ sleeper: Sleeper) {
        let wake = state.withLock { state in
            switch (state.cancelledSleeperIDs.contains(sleeper.id), sleeper.deadline <= state.now) {
            case (true, _): return Wake.cancelled
            case (false, true): return Wake.now
            case (false, false):
                state.sleepers.append(sleeper)
                return Wake.later
            }
        }

        switch wake {
        case .later: break
        case .now: sleeper.continuation.resume()
        case .cancelled: sleeper.continuation.resume(throwing: CancellationError())
        }
    }

    func cancelSleeper(id: Int) {
        let cancelled = state.withLock { state in
            guard let index = state.sleepers.firstIndex(where: { $0.id == id }) else {
                state.cancelledSleeperIDs.insert(id)
                return Sleeper?.none
            }

            return state.sleepers.remove(at: index)
        }

        cancelled?.continuation.resume(throwing: CancellationError())
    }
}
