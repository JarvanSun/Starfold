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
    @Bindable var settings: SettingsViewModel

    let stream: StreamViewModel
    let pictureInPicture: StreamPictureInPicture?
    let isFullScreen: Bool

    let onClose: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: dimensions.spaceSmall) {
            HStack(spacing: dimensions.spaceSmall) {
                guideButton

                statisticsToggle

                PictureMenu(settings: settings, stream: stream)

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
}

private extension StreamControlBar {
    var guideButton: some View {
        Button(action: stream.openGuide) {
            Label(String(localized: "stream.controlBar.guide.label"), systemImage: "logo.xbox")
        }
        .help(Text("stream.controlBar.guide.tooltip"))
    }

    var statisticsToggle: some View {
        Toggle(isOn: $settings.shouldShowStatistics) {
            Label(
                String(localized: "stream.controlBar.statistics.label"),
                systemImage: "chart.bar.xaxis"
            )
        }
        .toggleStyle(.button)
        .help(Text("stream.controlBar.statistics.tooltip"))
    }

    var fullScreenButton: some View {
        Button(action: toggleFullScreen) {
            fullScreenLabel
        }
    }

    @ViewBuilder
    var fullScreenLabel: some View {
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

    var disconnectButton: some View {
        Button(role: .destructive, action: onClose) {
            Label(String(localized: "stream.controlBar.disconnect.label"), systemImage: "xmark")
        }
        .help(Text("stream.controlBar.disconnect.tooltip"))
    }

    func pictureInPictureButton(_ pictureInPicture: StreamPictureInPicture) -> some View {
        Button(action: pictureInPicture.toggle) {
            Label(
                String(localized: "stream.controlBar.pictureInPicture.label"),
                systemImage: "pip.enter"
            )
        }
        .disabled(!pictureInPicture.isPossible)
        .help(Text("stream.controlBar.pictureInPicture.tooltip"))
    }

    func toggleFullScreen() {
        NSApp.keyWindow?.toggleFullScreen(nil)
    }
}

#if DEBUG
#Preview {
    VStack {
        StreamControlBar(
            settings: PreviewObjectPool.settingsViewModel,
            stream: PreviewObjectPool.streamViewModel(phase: .streaming),
            pictureInPicture: nil,
            isFullScreen: false
        ) {}

        StreamControlBar(
            settings: PreviewObjectPool.settingsViewModel,
            stream: PreviewObjectPool.streamViewModel(phase: .streaming),
            pictureInPicture: nil,
            isFullScreen: true
        ) {}
    }
    .padding()
    .background(.black)
}
#endif
