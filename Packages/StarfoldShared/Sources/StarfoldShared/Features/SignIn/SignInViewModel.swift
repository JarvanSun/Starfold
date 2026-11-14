//
//  SignInViewModel.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/10/01.
//

import Foundation
import Observation
import XboxKit
import os

@Observable
public final class SignInViewModel {
    public private(set) var attempt = 0
    public private(set) var shouldClose = false
    public private(set) var step = SignInStep.preparing

    private let signInService: SigningIn
    private let clock: any Clock<Duration>
    private let log = Logger(category: .signIn)

    public var welcomeFeatures: [WelcomeFeature] {
        WelcomeFeature.allCases
    }

    init(signInService: SigningIn, clock: some Clock<Duration>) {
        self.signInService = signInService
        self.clock = clock
    }

    public func run() async {
        show(.requesting)

        while !Task.isCancelled {
            do {
                let prompt = try await signInService.beginSignIn()
                show(.waiting(prompt))

                try await signInService.completeSignIn(prompt) { [weak self] in
                    self?.show(.finishing)
                }

                show(.done)

                await closeAfterShowingSuccess()

                return
            } catch is CancellationError {
                return
            } catch DeviceCodeError.expired {
                continue
            } catch DeviceCodeError.declined {
                show(.failed(String(localized: "signIn.failure.declined", bundle: .module)))

                return
            } catch {
                guard !Task.isCancelled else { return }

                log.error("Sign-in failed: \(String(describing: error), privacy: .public)")

                show(
                    .failed(
                        String(
                            localized: "signIn.failure.generic \(error.localizedDescription)",
                            bundle: .module
                        )
                    )
                )

                return
            }
        }
    }

    private func show(_ phase: SignInPhase) {
        step = phase.makeStep()
    }

    private func closeAfterShowingSuccess() async {
        let successPause: Duration = .milliseconds(900)

        try? await clock.sleep(for: successPause)

        guard !Task.isCancelled else { return }

        shouldClose = true
    }

    public func retry() {
        attempt += 1
    }
}
