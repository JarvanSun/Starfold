//
//  ConsoleCover.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Foundation
import XboxKit

public enum ConsoleCover {
    case game(URL)
    case lastFrame(CGImage)
    case placeholder

    init(activity: ConsoleActivity?, lastFrame: CGImage?) {
        switch (lastFrame, activity?.imageURL) {
        case (let lastFrame?, _): self = .lastFrame(lastFrame)
        case (nil, let artwork?): self = .game(artwork)
        case (nil, nil): self = .placeholder
        }
    }
}
