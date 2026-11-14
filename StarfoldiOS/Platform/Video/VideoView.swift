//
//  VideoView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import SwiftUI

struct VideoView: UIViewRepresentable {
    let renderer: StreamRenderer

    func makeUIView(context: Context) -> VideoHostView {
        .init(renderer: renderer)
    }

    func updateUIView(_ view: VideoHostView, context: Context) {}
}
