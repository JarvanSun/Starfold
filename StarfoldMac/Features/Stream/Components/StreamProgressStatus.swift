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
        VStack(spacing: dimensions.spaceLarge) {
            ConnectingIndicator()
                .padding(.vertical, dimensions.spaceSmall)

            Text(title)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.opacity)
                .multilineTextAlignment(.center)

            Button(String(localized: "stream.status.cancel"), action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.cancelAction)
        }
    }
}

#if DEBUG
#Preview {
    StreamProgressStatus(title: StreamStatus.connecting.title) {}
        .padding()
        .background(.black)
}
#endif
