//
//  StreamCoverView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamCoverView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        content
            .onDisappear { endStream() }
    }

    @ViewBuilder
    private var content: some View {
        switch app.stream {
        case let stream?: streamView(stream)
        case nil: noStream
        }
    }

    private func streamView(_ stream: StreamViewModel) -> some View {
        StreamView(stream: stream, settings: app.settings, controllers: app.controllers) {
            dismiss()
        }
        .id(ObjectIdentifier(stream))
    }

    private var noStream: some View {
        ContentUnavailableView("stream.empty.title", systemImage: "gamecontroller")
            .background(.black)
    }

    private func endStream() {
        Task { await app.endStream() }
    }
}

#if DEBUG
#Preview("Streaming") {
    StreamCoverView()
        .environment(PreviewObjectPool.appViewModel(streamPhase: .streaming))
}
#endif
