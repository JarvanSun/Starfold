//
//  StreamMenuView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dimensions) private var dimensions
    @Bindable var settings: SettingsViewModel

    let stream: StreamViewModel

    let onDisconnect: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            Button {
                openGuide()
            } label: {
                row("stream.menu.guide", symbol: "xbox.logo")
            }

            Toggle(isOn: $settings.shouldShowStatistics) {
                row("stream.menu.statistics", symbol: "chart.bar.fill")
            }

            Button {
                stream.showNextPictureFit()
            } label: {
                HStack {
                    row("stream.menu.pictureMode", symbol: "rectangle.arrowtriangle.2.outward")

                    Text(settings.pictureFit.title)
                        .foregroundStyle(.secondary)
                }
            }

            Button(role: .destructive) {
                disconnect()
            } label: {
                row("stream.menu.disconnect", symbol: "xmark.circle")
            }
        }
        .frame(width: dimensions.streamMenuWidth)
        .padding(dimensions.spaceXXXLarge)
        .presentationSizing(.fitted)
    }
}

private extension StreamMenuView {
    func row(_ title: LocalizedStringResource, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func openGuide() {
        stream.openGuide()

        dismiss()
    }

    func disconnect() {
        dismiss()

        onDisconnect()
    }
}

#if DEBUG
#Preview {
    StreamMenuView(
        settings: PreviewObjectPool.settingsViewModel,
        stream: PreviewObjectPool.cloudStreamViewModel(phase: .streaming),
        onDisconnect: {}
    )
}
#endif
