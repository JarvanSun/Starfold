//
//  StreamPicture.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
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
                .opacity(isVisible ? 1 : 0)
                .ignoresSafeArea()
        case nil: EmptyView()
        }
    }
}

#if DEBUG
#Preview {
    StreamPicture(
        renderer: PreviewObjectPool.streamViewModel(phase: .streaming).renderer,
        isVisible: true
    )
}
#endif
