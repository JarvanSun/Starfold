//
//  MessageEnvelopeType.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum MessageEnvelopeType: String {
    case handshake = "Handshake"
    case handshakeAcknowledgement = "HandshakeAck"
    case message = "Message"
    case transactionStart = "TransactionStart"
    case transactionComplete = "TransactionComplete"
    case senderCancel = "SenderCancel"
    case receiverCancel = "ReceiverCancel"
    case unhandled = "Unhandled"
}
