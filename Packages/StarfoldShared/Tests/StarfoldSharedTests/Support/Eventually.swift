//
//  Eventually.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

struct Eventually {
    private let timeout: Duration
    private let pollInterval: Duration

    init(timeout: Duration = .seconds(2), pollInterval: Duration = .milliseconds(10)) {
        self.timeout = timeout
        self.pollInterval = pollInterval
    }

    @discardableResult
    func holds(_ condition: () -> Bool) async -> Bool {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout

        while clock.now < deadline {
            guard !condition() else { return true }

            try? await Task.sleep(for: pollInterval)
        }

        return condition()
    }
}
