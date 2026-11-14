//
//  TouchControlStyle.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchControlStyle: Sendable, Hashable, Decodable {
    private enum CodingKeys: String, CodingKey {
        case faceImage
        case background
        case knob
        case opacity
    }

    public var faceImage: TouchImage?
    public var background: TouchImage?
    public var knob: TouchKnobStyle?
    public var opacity: Double

    public init(
        faceImage: TouchImage? = nil,
        background: TouchImage? = nil,
        knob: TouchKnobStyle? = nil,
        opacity: Double = 1
    ) {
        self.faceImage = faceImage
        self.background = background
        self.knob = knob
        self.opacity = opacity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        faceImage = try container.decodeIfPresent(TouchImage.self, forKey: .faceImage)
        background = try container.decodeIfPresent(TouchImage.self, forKey: .background)
        knob = try container.decodeIfPresent(TouchKnobStyle.self, forKey: .knob)
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1
    }
}
