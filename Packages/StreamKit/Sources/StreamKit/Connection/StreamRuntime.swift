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
    private var factory: LKRTCPeerConnectionFactory?
    #if os(macOS)
    private let audioDevice = MacStereoAudioDevice()
    #else
    private let audioDevice = StereoAudioDevice()
    #endif

    public init() {}

    #if !os(macOS)
    public func setDirectStereo(_ isEnabled: Bool) {
        audioDevice.setBypassesSpatialAudio(isEnabled)
    }
    #endif

    func peerConnectionFactory() -> LKRTCPeerConnectionFactory {
        lock.withLock {
            let factory = factory ?? makeFactory()
            self.factory = factory
            return factory
        }
    }
}

private extension StreamRuntime {
    func makeFactory() -> LKRTCPeerConnectionFactory {
        enableNetworkPathMonitor()

        LKRTCInitializeSSL()

        let factory = LKRTCPeerConnectionFactory(
            encoderFactory: LKRTCDefaultVideoEncoderFactory(),
            decoderFactory: XboxVideoDecoderFactory(),
            audioDevice: audioDevice
        )
        let options = LKRTCPeerConnectionFactoryOptions()
        options.ignoreLoopbackNetworkAdapter = true
        factory.setOptions(options)

        return factory
    }

    func enableNetworkPathMonitor() {
        #if !os(macOS)
        LKRTCInitFieldTrialDictionary([
            kLKRTCFieldTrialUseNWPathMonitor: kLKRTCFieldTrialEnabledValue
        ])
        #endif
    }
}
