//
//  PictureFitPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

extension PictureFit {
    public var title: LocalizedStringResource {
        switch self {
        case .fit: .init("stream.pictureFit.fit", bundle: .module)
        case .fill: .init("stream.pictureFit.fill", bundle: .module)
        case .scale: .init("stream.pictureFit.scale", bundle: .module)
        }
    }
}
