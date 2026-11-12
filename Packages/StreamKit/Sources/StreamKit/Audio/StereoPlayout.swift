//
//  StereoPlayout.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import AVFAudio
@preconcurrency import LiveKitWebRTC

struct StereoPlayout {
    let meter: PlayoutMeter

    var sampleRate: Double { 48_000 }

    func makeSource(
        pulling pull: @escaping LKRTCAudioDeviceGetPlayoutDataBlock
    ) -> (node: AVAudioSourceNode, format: AVAudioFormat)? {
        guard let layout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo) else {
            return nil
        }

        let webRTCFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            interleaved: true,
            channelLayout: layout
        )
        let stereo = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channelLayout: layout)
        let meter = meter
        let node = AVAudioSourceNode(format: webRTCFormat) {
            isSilence,
            timestamp,
            frameCount,
            output in
            var flags = AudioUnitRenderActionFlags()
            let status = pull(&flags, timestamp, 0, frameCount, output)

            if flags.contains(.unitRenderAction_OutputIsSilence) {
                isSilence.pointee = true
            }

            meter.record(output, frames: Int(frameCount))

            return status
        }
        return (node, stereo)
    }
}
