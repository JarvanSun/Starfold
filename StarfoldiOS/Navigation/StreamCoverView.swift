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
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dismiss) private var dismiss

    @ViewBuilder
    var body: some View {
        switch appViewModel.stream {
        case let streamViewModel?: streamView(streamViewModel)
        case nil: noStream
        }
    }

    private func streamView(_ streamViewModel: StreamViewModel) -> some View {
        StreamView(
            streamViewModel: streamViewModel,
            settingsViewModel: appViewModel.settings,
            controllers: appViewModel.controllers
        ) {
            dismiss()
        }
        .id(ObjectIdentifier(streamViewModel))
    }

    private var noStream: some View {
        ContentUnavailableView("stream.empty.title", systemImage: "gamecontroller")
            .background(.black)
    }
}

#if DEBUG
#Preview("Streaming") {
    StreamCoverView()
        .environment(PreviewObjectPool.appViewModel(streamPhase: .streaming))
}
#endif
