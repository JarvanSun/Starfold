//
//  StreamRuntime.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
@preconcurrency import LiveKitWebRTC

public final class StreamRuntime: @unchecked Sendable {
    private let lock = NSLock()
    #if os(macOS)
    private let audioDevice = MacStereoAudioDevice()
    #else
    private let audioDevice = StereoAudioDevice()
    #endif

    private var connectionFactory: LKRTCPeerConnectionFactory?

    public init() {}

    #if !os(macOS)
    public func setDirectStereo(_ isEnabled: Bool) {
        audioDevice.setBypassesSpatialAudio(isEnabled)
    }
    #endif

    func peerConnectionFactory() -> LKRTCPeerConnectionFactory {
        lock.withLock {
            let connectionFactory = connectionFactory ?? makeFactory()
            self.connectionFactory = connectionFactory
            return connectionFactory
        }
    }

    private func makeFactory() -> LKRTCPeerConnectionFactory {
        enableNetworkPathMonitor()

        LKRTCInitializeSSL()

        let connectionFactory = LKRTCPeerConnectionFactory(
            encoderFactory: LKRTCDefaultVideoEncoderFactory(),
            decoderFactory: XboxVideoDecoderFactory(),
            audioDevice: audioDevice
        )
        let options = LKRTCPeerConnectionFactoryOptions()
        options.ignoreLoopbackNetworkAdapter = true
        connectionFactory.setOptions(options)

        return connectionFactory
    }

    private func enableNetworkPathMonitor() {
        #if !os(macOS)
        LKRTCInitFieldTrialDictionary([
            kLKRTCFieldTrialUseNWPathMonitor: kLKRTCFieldTrialEnabledValue
        ])
        #endif
    }
}
