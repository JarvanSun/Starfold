//
//  ConsolePowerControl.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public enum ConsolePowerControl: Equatable {
    case command(XboxLiveClient.PowerCommand)
    case sending(XboxLiveClient.PowerCommand)
    case unavailable
}
