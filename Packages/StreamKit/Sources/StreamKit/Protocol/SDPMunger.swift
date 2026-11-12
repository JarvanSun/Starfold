//
//  SDPMunger.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

struct SDPMunger {
    func forcingStereoOpus(_ sdp: String) -> String {
        var lines = sdp.components(separatedBy: lineBreak)
        let opusPayloads = opusPayloadTypes(in: lines)

        for index in lines.indices {
            if let rewritten = stereoFormatLine(lines[index], opusPayloads: opusPayloads) {
                lines[index] = rewritten
            }
        }

        return lines.joined(separator: lineBreak)
    }

    func limitingVideoBitrate(_ sdp: String, kbps: Int) -> String {
        var lines = sdp.components(separatedBy: lineBreak)
        guard let videoStart = lines.firstIndex(where: { $0.hasPrefix("m=video") }) else {
            return sdp
        }

        let sectionEnd =
            lines[(videoStart + 1)...].firstIndex { $0.hasPrefix("m=") } ?? lines.endIndex
        let existing = lines[(videoStart + 1)..<sectionEnd].firstIndex { $0.hasPrefix("b=AS:") }

        switch existing {
        case let existing?:
            lines[existing] = "b=AS:\(kbps)"
        case nil:
            lines.insert(
                "b=AS:\(kbps)",
                at: bandwidthLineIndex(in: lines, after: videoStart, before: sectionEnd)
            )
        }

        return lines.joined(separator: lineBreak)
    }

    func preferredH264Order(mimeTypes: [String], profileLevelIDs: [String?]) -> [Int] {
        mimeTypes.indices.sorted { lhs, rhs in
            let (lhsRank, rhsRank) = (
                rank(mimeType: mimeTypes[lhs], profileLevelID: profileLevelIDs[lhs]),
                rank(mimeType: mimeTypes[rhs], profileLevelID: profileLevelIDs[rhs])
            )
            return lhsRank == rhsRank ? lhs < rhs : lhsRank < rhsRank
        }
    }
}

private extension SDPMunger {
    var lineBreak: String { "\r\n" }

    var replacedOpusParameters: Set<String> {
        ["stereo", "minptime", "useinbandfec", "sprop-stereo"]
    }

    var stereoOpusParameters: [String] { ["stereo=1", "minptime=10", "useinbandfec=1"] }

    func opusPayloadTypes(in lines: [String]) -> Set<String> {
        Set(
            lines.compactMap { line -> String? in
                guard line.hasPrefix("a=rtpmap:"), line.lowercased().contains(" opus/"),
                    let payload = line.dropFirst("a=rtpmap:".count).split(separator: " ").first
                else { return nil }

                return String(payload)
            }
        )
    }

    func stereoFormatLine(_ line: String, opusPayloads: Set<String>) -> String? {
        guard line.hasPrefix("a=fmtp:") else { return nil }

        let rest = line.dropFirst("a=fmtp:".count)
        guard let space = rest.firstIndex(of: " ") else { return nil }

        let payload = String(rest[..<space])
        guard opusPayloads.contains(payload) else { return nil }

        let kept = rest[rest.index(after: space)...]
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { parameter in
                let name = parameter.split(separator: "=").first.map(String.init) ?? ""
                return !replacedOpusParameters.contains(name) && !parameter.isEmpty
            }
        return "a=fmtp:\(payload) " + (kept + stereoOpusParameters).joined(separator: ";")
    }

    func bandwidthLineIndex(in lines: [String], after videoStart: Int, before sectionEnd: Int)
        -> Int
    {
        var index = videoStart + 1

        while index < sectionEnd, lines[index].hasPrefix("i=") || lines[index].hasPrefix("c=") {
            index += 1
        }

        return index
    }

    func rank(mimeType: String, profileLevelID: String?) -> Int {
        let mime = mimeType.lowercased()
        guard mime == "video/h264" else {
            return mime.hasSuffix("/rtx") || mime.hasSuffix("/red") ? 100 : 50
        }

        let profile = profileLevelID?.lowercased() ?? ""
        return switch profile {
        case _ where profile.hasPrefix("4d"): 0
        case _ where profile.hasPrefix("42e"): 1
        case _ where profile.hasPrefix("420"): 2
        default: 3
        }
    }
}
