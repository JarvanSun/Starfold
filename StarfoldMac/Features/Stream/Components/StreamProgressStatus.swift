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
    let isXboxButtonTakenBySystem: Bool

    let onOpenXboxButtonSettings: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            ConnectingIndicator()
                .padding(.vertical, dimensions.spaceSmall)

            Text(title)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.opacity)
                .multilineTextAlignment(.center)

            Button(String(localized: "stream.status.cancel")) { onCancel() }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.cancelAction)

            if isXboxButtonTakenBySystem {
                xboxButtonNotice
            }
        }
    }

    private var xboxButtonNotice: some View {
        VStack(spacing: dimensions.spaceXSmall) {
            Text("stream.status.xboxButton.notice")
                .foregroundStyle(.white.opacity(0.7))

            Button(String(localized: "stream.status.xboxButton.openSettings")) {
                onOpenXboxButtonSettings()
            }
            .buttonStyle(.link)
        }
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding(.top, dimensions.spaceSmall)
    }
}

#if DEBUG
#Preview {
    StreamProgressStatus(
        title: StreamStatus.connecting.title,
        isXboxButtonTakenBySystem: true,
        onOpenXboxButtonSettings: {},
        onCancel: {}
    )
    .padding()
    .background(.black)
}
#endif
