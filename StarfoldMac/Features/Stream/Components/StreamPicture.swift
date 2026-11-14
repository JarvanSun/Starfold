//
//  StreamPicture.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamPicture: View {
    let renderer: StreamRenderer?
    let isVisible: Bool
    let pictureInPicture: StreamPictureInPicture?

    var body: some View {
        if let renderer {
            StreamVideoView(renderer: renderer, pictureInPicture: pictureInPicture)
                .opacity(isVisible ? 1 : 0)
        }
    }
}

#if DEBUG
#Preview {
    StreamPicture(
        renderer: PreviewObjectPool.streamViewModel(phase: .streaming).renderer,
        isVisible: true,
        pictureInPicture: nil
    )
    .frame(width: 640, height: 360)
}
#endif
