//
//  SoundStagePresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension SoundStage {
    public var title: LocalizedStringResource {
        switch self {
        case .window: .init("stream.soundStage.window", bundle: .module)
        case .direct: .init("stream.soundStage.direct", bundle: .module)
        }
    }
}
