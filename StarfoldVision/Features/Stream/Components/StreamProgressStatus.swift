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

    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            ProgressView()
                .controlSize(.large)

            Text(title)
                .font(.title3)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)

            Button("stream.status.cancel", action: onCancel)
                .controlSize(.large)
        }
    }
}

#if DEBUG
#Preview {
    StreamProgressStatus(title: StreamStatus.connecting.title) {}
        .padding()
}
#endif
