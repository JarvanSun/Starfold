//
//  StreamProgressStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamProgressStatus: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    var isXboxButtonTakenBySystem = false

    var onOpenXboxButtonSettings: () -> Void = {}
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            ProgressView()
                .controlSize(.large)

            Text(title)
                .font(.title3)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)

            Button("stream.status.cancel") { onCancel() }
                .controlSize(.large)

            if isXboxButtonTakenBySystem {
                xboxButtonNotice
            }
        }
    }

    private var xboxButtonNotice: some View {
        VStack(spacing: dimensions.spaceSmall) {
            Text("stream.status.xboxButton.notice")
                .foregroundStyle(.secondary)

            Button("stream.status.xboxButton.openSettings") { onOpenXboxButtonSettings() }
                .buttonStyle(.borderless)
        }
        .font(.callout)
        .multilineTextAlignment(.center)
    }
}

#if DEBUG
#Preview {
    StreamProgressStatus(title: StreamStatus.connecting.title, isXboxButtonTakenBySystem: true) {}
        .padding()
}
#endif
