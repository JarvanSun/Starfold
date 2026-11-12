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
    private let service: SigningIn
    private let clock: any Clock<Duration>

    public private(set) var attempt = 0
    public private(set) var shouldClose = false
    private(set) var phase = SignInPhase.requesting
    private let log = Logger(category: .signIn)

    public var step: SignInStep {
        switch phase {
        case .requesting: .preparing
        case .waiting(let prompt): .code(.init(prompt: prompt))
        case .finishing: .progress(.signingIn)
        case .done: .progress(.signedIn)
        case .failed(let message): .failure(message)
        }
    }

    public var welcomeFeatures: [WelcomeFeature] {
        WelcomeFeature.allCases
    }

    init(service: SigningIn, clock: some Clock<Duration>) {
        self.service = service
        self.clock = clock
    }

    public func run() async {
        phase = .requesting

        while !Task.isCancelled {
            do {
                let prompt = try await service.beginSignIn()
                phase = .waiting(prompt)

                try await service.completeSignIn(prompt) { [weak self] in self?.phase = .finishing }

                phase = .done

                await closeAfterShowingSuccess()

                return
            } catch is CancellationError {
                return
            } catch DeviceCodeError.expired {
                continue
            } catch DeviceCodeError.declined {
                phase = .failed(String(localized: "signIn.failure.declined", bundle: .module))

                return
            } catch {
                guard !Task.isCancelled else { return }

                log.error("Sign-in failed: \(String(describing: error), privacy: .public)")

                phase = .failed(
                    String(
                        localized: "signIn.failure.generic \(error.localizedDescription)",
                        bundle: .module
                    )
                )

                return
            }
        }
    }

    public func retry() {
        attempt += 1
    }
}

private extension SignInViewModel {
    var successPause: Duration {
        .milliseconds(900)
    }

    func closeAfterShowingSuccess() async {
        try? await clock.sleep(for: successPause)

        guard !Task.isCancelled else { return }

        shouldClose = true
    }
}
