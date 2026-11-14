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
    @Environment(AppViewModel.self) private var appViewModel
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
            .onDisappear { endStream() }
    }

    @ViewBuilder
    private var content: some View {
        switch appViewModel.streamViewModel {
        case let stream?: streamView(stream)
        case nil: noStream
        }
    }

    private func streamView(_ stream: StreamViewModel) -> some View {
        StreamView(streamViewModel: stream, settingsViewModel: appViewModel.settingsViewModel) {
            dismissWindow()
        }
        .id(ObjectIdentifier(stream))
    }

    private var noStream: some View {
        ContentUnavailableView("stream.empty.title", systemImage: "gamecontroller")
            .glassBackgroundEffect()
    }

    private func endStream() {
        Task { await appViewModel.endStream() }
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
