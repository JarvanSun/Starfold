//
//  StreamControlBar.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamControlBar: View {
    @Environment(\.dimensions) private var dimensions
    @State private var isShowingOptions = false
    @Bindable var settings: SettingsViewModel

    let stream: StreamViewModel

    let onDisconnect: () -> Void

    var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            guideButton

            statisticsToggle

            optionsButton

            disconnectButton
        }
        .labelStyle(.iconOnly)
        .toggleStyle(.button)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .padding(dimensions.spaceMedium)
        .glassBackgroundEffect()
        .padding(.top, dimensions.spaceLarge)
    }
}

private extension StreamControlBar {
    var guideButton: some View {
        Button {
            stream.openGuide()
        } label: {
            Label("stream.controls.guide", systemImage: "logo.xbox")
        }
    }

    var statisticsToggle: some View {
        Toggle(isOn: $settings.shouldShowStatistics) {
            Label("stream.controls.statistics", systemImage: "chart.bar.xaxis")
        }
    }

    var optionsButton: some View {
        Button {
            isShowingOptions = true
        } label: {
            Label("stream.controls.options", systemImage: "slider.horizontal.3")
        }
        .popover(isPresented: $isShowingOptions, arrowEdge: .bottom) {
            StreamOptionsView(settings: settings)
        }
    }

    var disconnectButton: some View {
        Button(role: .destructive) {
            onDisconnect()
        } label: {
            Label("stream.controls.disconnect", systemImage: "xmark")
        }
    }
}

#if DEBUG
#Preview("Control bar") {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    StreamControlBar(
        settings: preview.settings,
        stream: preview.stream
    ) {}
}
#endif
