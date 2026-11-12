//
//  StreamVideoView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import AppKit
import StreamKit
import SwiftUI

struct StreamVideoView: NSViewRepresentable {
    let renderer: StreamRenderer
    let pictureInPicture: StreamPictureInPicture?

    func makeNSView(context: Context) -> StreamVideoHostView {
        .init(renderer: renderer)
    }

    func updateNSView(_ view: StreamVideoHostView, context: Context) {
        pictureInPicture?.host = view
    }
}
