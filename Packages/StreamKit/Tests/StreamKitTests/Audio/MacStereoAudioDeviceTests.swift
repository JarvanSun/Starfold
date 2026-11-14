//
//  MacStereoAudioDeviceTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/09/30.
//

#if os(macOS)
import Foundation
import Synchronization
import Testing
@testable import StreamKit

@Suite(.enabled(if: AudioOutputAvailability().hasDefaultOutput, "needs an audio output device"))
struct MacStereoAudioDeviceTests {
    @Test
    func startPlayoutThenPullsShortBuffersAndReportsThemToWebRTC() async throws {
        // Given
        let device = MacStereoAudioDevice()
        let delegate = AudioDeviceDelegateStub()

        // When
        let didStart = delegate.onQueue {
            device.initialize(with: delegate) && device.initializePlayout() && device.startPlayout()
        }

        let hasPulled = await Eventually().holds {
            delegate.counter.pulls.load(ordering: .relaxed) >= enoughPulls
        }
        let (largestPull, latency, ioBuffer) = delegate.onQueue {
            (
                delegate.counter.largestPull.load(ordering: .relaxed),
                device.outputLatency,
                device.outputIOBufferDuration
            )
        }

        delegate.onQueue { device.stopPlayout() && device.terminateDevice() }

        // Then
        #expect(didStart)
        #expect(hasPulled)
        #expect(delegate.outputParameterChanges.load(ordering: .relaxed) >= 1)
        #expect(Double(largestPull) <= ioBuffer * device.stereoPlayout.sampleRate * 1.1 + 16)
        #expect(latency >= ioBuffer)
    }
}

private extension MacStereoAudioDeviceTests {
    var enoughPulls: Int {
        10
    }
}
#endif
