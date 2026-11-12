//
//  VideoView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import SwiftUI

struct VideoView: UIViewRepresentable {
    let renderer: StreamRenderer

    func makeUIView(context: Context) -> VideoSurface {
        .init(renderer: renderer)
    }

    func updateUIView(_ view: VideoSurface, context: Context) {}
}
