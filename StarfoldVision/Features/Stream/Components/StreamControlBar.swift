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
    @Bindable var settingsViewModel: SettingsViewModel

    let streamViewModel: StreamViewModel

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

    private var guideButton: some View {
        Button {
            streamViewModel.openGuide()
        } label: {
            Label("stream.controls.guide", systemImage: "logo.xbox")
        }
    }

    private var statisticsToggle: some View {
        Toggle(isOn: $settingsViewModel.shouldShowStatistics) {
            Label("stream.controls.statistics", systemImage: "chart.bar.xaxis")
        }
    }

    private var optionsButton: some View {
        Button {
            isShowingOptions = true
        } label: {
            Label("stream.controls.options", systemImage: "slider.horizontal.3")
        }
        .popover(isPresented: $isShowingOptions, arrowEdge: .bottom) {
            StreamOptionsView(settingsViewModel: settingsViewModel)
        }
    }

    private var disconnectButton: some View {
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
        settingsViewModel: preview.settingsViewModel,
        streamViewModel: preview.streamViewModel
    ) {}
}
#endif
