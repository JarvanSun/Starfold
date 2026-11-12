//
//  StreamWindowView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamWindowView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        content
            .frame(
                minWidth: dimensions.streamWindowMinimumWidth,
                idealWidth: dimensions.streamWindowWidth,
                minHeight: dimensions.streamWindowMinimumHeight,
                idealHeight: dimensions.streamWindowHeight
            )
            .onDisappear(perform: endStream)
    }
}

private extension StreamWindowView {
    @ViewBuilder
    var content: some View {
        switch app.stream {
        case let stream?: streamView(stream)
        case nil: noStream
        }
    }

    func streamView(_ stream: StreamViewModel) -> some View {
        StreamView(stream: stream, settings: app.settings) { dismissWindow() }
            .id(ObjectIdentifier(stream))
    }

    var noStream: some View {
        ContentUnavailableView("stream.empty.title", systemImage: "gamecontroller")
            .glassBackgroundEffect()
    }

    func endStream() {
        Task { await app.endStream() }
    }
}

#if DEBUG
#Preview("Streaming", windowStyle: .plain) {
    StreamWindowView()
        .environment(PreviewObjectPool.appViewModel(streamPhase: .streaming))
}

#Preview("No stream", windowStyle: .plain) {
    StreamWindowView()
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
