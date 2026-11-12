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

    var body: some View {
        switch renderer {
        case let renderer?:
            VideoView(renderer: renderer)
                .background(.black)
                .opacity(isVisible ? 1 : 0)
        case nil: EmptyView()
        }
    }
}

#if DEBUG
#Preview(windowStyle: .plain) {
    StreamPicture(
        renderer: PreviewObjectPool.streamViewModel(phase: .streaming).renderer,
        isVisible: true
    )
    .frame(width: 1280, height: 720)
}
#endif
