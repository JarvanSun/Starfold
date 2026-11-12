//
//  StringDummy.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension String {
    static var dummySDPOffer: String {
        [
            "v=0",
            "m=audio 9 UDP/TLS/RTP/SAVPF 111 63",
            "c=IN IP4 0.0.0.0",
            "a=rtpmap:111 opus/48000/2",
            "a=fmtp:111 minptime=10;useinbandfec=1",
            "m=video 9 UDP/TLS/RTP/SAVPF 96 97",
            "c=IN IP4 0.0.0.0",
            "a=rtpmap:96 H264/90000",
            "",
        ]
        .joined(separator: "\r\n")
    }
}
