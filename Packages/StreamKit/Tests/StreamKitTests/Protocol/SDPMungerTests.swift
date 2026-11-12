//
//  SDPMungerTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct SDPMungerTests {
    @Test
    func forcingStereoOpusThenAddsStereoWithoutDuplicatingParameters() {
        // Given
        let munger = SDPMunger()

        // When
        let munged = munger.forcingStereoOpus(.dummySDPOffer)

        // Then
        #expect(munged.contains("a=fmtp:111 stereo=1;minptime=10;useinbandfec=1"))
        #expect(!munged.contains("minptime=10;useinbandfec=1;stereo"))
    }

    @Test

    func limitingVideoBitrateThenPlacesOneBandwidthLineAfterTheConnectionLine() throws {
        // Given
        let munger = SDPMunger()

        // When
        let munged = munger.limitingVideoBitrate(.dummySDPOffer, kbps: 20_000)

        // Then
        let lines = munged.components(separatedBy: "\r\n")
        let video = try #require(lines.firstIndex(of: "m=video 9 UDP/TLS/RTP/SAVPF 96 97"))
        #expect(lines[video + 2] == "b=AS:20000")
        #expect(lines.filter { $0.hasPrefix("b=AS") }.count == 1)
    }

    @Test

    func preferredH264OrderThenPutsMainFirstAndRetransmissionLast() {
        // Given
        let munger = SDPMunger()

        // When
        let order = munger.preferredH264Order(
            mimeTypes: ["video/VP8", "video/rtx", "video/H264", "video/H264", "video/H264"],
            profileLevelIDs: [nil, nil, "42001f", "42e01f", "4d001f"]
        )

        // Then
        #expect(order == [4, 3, 2, 0, 1])
    }
}
