//
//  SessionState.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum SessionState: Equatable, Sendable {
    case provisioning
    case waitingForResources
    case readyToConnect
    case provisioned
    case failed(code: String?, message: String?)
    case other(String)

    init(fields: [String: Any]) {
        let state = fields["state"] as? String ?? ""

        switch state {
        case "Provisioning": self = .provisioning
        case "WaitingForResources": self = .waitingForResources
        case "ReadyToConnect": self = .readyToConnect
        case "Provisioned": self = .provisioned
        case "Failed":
            let details = fields["errorDetails"] as? [String: Any]
            self = .failed(
                code: details?["code"] as? String,
                message: details?["message"] as? String
            )
        default: self = .other(state)
        }
    }
}
