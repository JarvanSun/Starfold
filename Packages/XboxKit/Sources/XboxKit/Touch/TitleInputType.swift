//
//  TitleInputType.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public enum TitleInputType: Sendable, Hashable, Decodable {
    private enum Name: String {
        case controller = "Controller"
        case mouseAndKeyboard = "MKB"
        case customTouchOverlay = "CustomTouchOverlay"
        case genericTouch = "GenericTouch"
        case nativeTouch = "NativeTouch"
        case nativeSensor = "NativeSensor"
    }

    case controller
    case mouseAndKeyboard
    case customTouchOverlay
    case genericTouch
    case nativeTouch
    case nativeSensor
    case unrecognized(String)

    public init(name: String) {
        switch Name(rawValue: name) {
        case .controller: self = .controller
        case .mouseAndKeyboard: self = .mouseAndKeyboard
        case .customTouchOverlay: self = .customTouchOverlay
        case .genericTouch: self = .genericTouch
        case .nativeTouch: self = .nativeTouch
        case .nativeSensor: self = .nativeSensor
        case nil: self = .unrecognized(name)
        }
    }

    public init(from decoder: Decoder) throws {
        self.init(name: try decoder.singleValueContainer().decode(String.self))
    }
}
