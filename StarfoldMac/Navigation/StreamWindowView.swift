//
//  StreamWindowView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamWindowView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        streamContent
            .frame(
                minWidth: dimensions.streamWindowMinimumWidth,
                minHeight: dimensions.streamWindowMinimumHeight
            )
            .background(.black)
            .preferredColorScheme(.dark)
            .onDisappear { endStream() }
    }
}

private extension StreamWindowView {
    @ViewBuilder
    var streamContent: some View {
        switch app.stream {
        case let stream?:
            StreamView(stream: stream, settings: app.settings, onClose: { closeWindow() })
                .id(ObjectIdentifier(stream))
        case nil: noStream
        }
    }

    var noStream: some View {
        ContentUnavailableView(
            String(localized: "stream.noStream.title"),
            systemImage: "gamecontroller"
        )
        .background { SkyBackground() }
    }

    func closeWindow() {
        dismissWindow(id: SceneID.stream.rawValue)
    }

    func endStream() {
        Task { await app.endStream() }
    }
}

#if DEBUG
#Preview("Connecting") {
    StreamWindowView()
        .frame(width: 1280, height: 720)
        .environment(PreviewObjectPool.appViewModel(streamPhase: .connecting))
}

#Preview("No stream") {
    StreamWindowView()
        .frame(width: 1280, height: 720)
        .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
