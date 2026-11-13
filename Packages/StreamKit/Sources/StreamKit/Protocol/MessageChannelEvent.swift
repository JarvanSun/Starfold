//
//  MessageChannelEvent.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum MessageChannelEvent: Equatable, Sendable {
    case handshakeAcknowledged
    case reply(Data)
    case dialog(SystemDialogRequest)
    case dialogCancelled(id: String)
    case serverDisconnect
    case touchControls(TouchControlsCommand)
    case runningTitle(RunningTitle)
}
