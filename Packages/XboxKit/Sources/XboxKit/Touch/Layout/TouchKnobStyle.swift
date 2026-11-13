//
//  TouchKnobStyle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchKnobStyle: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case faceImage
        case background
        case opacity
    }

    public var faceImage: TouchImage?
    public var background: TouchImage?
    public var opacity: Double

    public init(faceImage: TouchImage? = nil, background: TouchImage? = nil, opacity: Double = 1) {
        self.faceImage = faceImage
        self.background = background
        self.opacity = opacity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        faceImage = try container.decodeIfPresent(TouchImage.self, forKey: .faceImage)
        background = try container.decodeIfPresent(TouchImage.self, forKey: .background)
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1
    }
}
