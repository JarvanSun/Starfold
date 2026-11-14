//
//  StreamControlBar.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import AppKit
import StarfoldShared
import StreamKit
import SwiftUI

struct StreamControlBar: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var settingsViewModel: SettingsViewModel

    let streamViewModel: StreamViewModel
    let pictureInPicture: StreamPictureInPicture?
    let isFullScreen: Bool

    let onClose: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: dimensions.spaceSmall) {
            HStack(spacing: dimensions.spaceSmall) {
                guideButton

                statisticsToggle

                PictureMenu(settingsViewModel: settingsViewModel, streamViewModel: streamViewModel)

                switch pictureInPicture {
                case let pictureInPicture?: pictureInPictureButton(pictureInPicture)
                case nil: EmptyView()
                }

                fullScreenButton

                disconnectButton
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .controlSize(.large)
        }
        .environment(\.colorScheme, .dark)
    }

    private var guideButton: some View {
        Button {
            streamViewModel.openGuide()
        } label: {
            Label(String(localized: "stream.controlBar.guide.label"), systemImage: "logo.xbox")
        }
        .help(Text("stream.controlBar.guide.tooltip"))
    }

    private var statisticsToggle: some View {
        Toggle(isOn: $settingsViewModel.shouldShowStatistics) {
            Label(
                String(localized: "stream.controlBar.statistics.label"),
                systemImage: "chart.bar.xaxis"
            )
        }
        .toggleStyle(.button)
        .help(Text("stream.controlBar.statistics.tooltip"))
    }

    private func pictureInPictureButton(_ pictureInPicture: StreamPictureInPicture) -> some View {
        Button {
            pictureInPicture.toggle()
        } label: {
            Label(
                String(localized: "stream.controlBar.pictureInPicture.label"),
                systemImage: "pip.enter"
            )
        }
        .disabled(!pictureInPicture.isPossible)
        .help(Text("stream.controlBar.pictureInPicture.tooltip"))
    }

    private var fullScreenButton: some View {
        Button {
            toggleFullScreen()
        } label: {
            fullScreenLabel
        }
    }

    private func toggleFullScreen() {
        NSApp.keyWindow?.toggleFullScreen(nil)
    }

    @ViewBuilder
    private var fullScreenLabel: some View {
        switch isFullScreen {
        case true:
            Label(
                String(localized: "stream.controlBar.fullScreen.exit"),
                systemImage: "arrow.down.right.and.arrow.up.left"
            )
        case false:
            Label(
                String(localized: "stream.controlBar.fullScreen.enter"),
                systemImage: "arrow.up.left.and.arrow.down.right"
            )
        }
    }

    private var disconnectButton: some View {
        Button(role: .destructive) {
            onClose()
        } label: {
            Label(String(localized: "stream.controlBar.disconnect.label"), systemImage: "xmark")
        }
        .help(Text("stream.controlBar.disconnect.tooltip"))
    }
}

#if DEBUG
#Preview {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    VStack {
        StreamControlBar(
            settingsViewModel: preview.settingsViewModel,
            streamViewModel: preview.streamViewModel,
            pictureInPicture: nil,
            isFullScreen: false
        ) {}

        StreamControlBar(
            settingsViewModel: preview.settingsViewModel,
            streamViewModel: preview.streamViewModel,
            pictureInPicture: nil,
            isFullScreen: true
        ) {}
    }
    .padding()
    .background(.black)
}
#endif
