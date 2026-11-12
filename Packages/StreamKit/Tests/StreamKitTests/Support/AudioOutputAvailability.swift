//
//  AudioOutputAvailability.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if os(macOS)
import CoreAudio

struct AudioOutputAvailability {
    var hasDefaultOutput: Bool {
        var device = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &device
        )
        return status == noErr && device != kAudioObjectUnknown
    }
}
#endif
