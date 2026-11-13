//
//  PictureMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct PictureMenu: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var settings: SettingsViewModel
    @Bindable var stream: StreamViewModel

    var body: some View {
        Menu {
            upscalingToggle

            if settings.canToneMapHDR {
                toneMappingToggle
            }

            pictureFitPicker

            sharpeningPicker

            pacingPicker
        } label: {
            Label(String(localized: "stream.controlBar.picture.label"), systemImage: "sparkles.tv")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .frame(width: dimensions.pictureMenuWidth, height: dimensions.pictureMenuHeight)
        .contentShape(.capsule)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

private extension PictureMenu {
    var upscalingToggle: some View {
        Toggle(
            String(localized: "stream.controlBar.picture.upscaling"),
            isOn: $settings.isUpscalingEnabled
        )
    }

    var toneMappingToggle: some View {
        Toggle(
            String(localized: "stream.controlBar.picture.toneMapping"),
            isOn: $settings.isHDRToneMappingEnabled
        )
    }

    var pictureFitPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.pictureMode"),
            selection: $settings.pictureFit
        ) {
            ForEach(settings.pictureFits, id: \.self) { fit in
                Text(fit.title).tag(fit)
            }
        }
    }

    var sharpeningPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.sharpening.title"),
            selection: $stream.sharpeningLevel
        ) {
            ForEach(stream.sharpeningLevels, id: \.self) { level in
                Text(level.title).tag(level)
            }
        }
    }

    var pacingPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.buffer"),
            selection: $settings.pacingMode
        ) {
            ForEach(settings.pacingModes, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        }
    }
}

#if DEBUG
#Preview {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    PictureMenu(
        settings: preview.settings,
        stream: preview.stream
    )
    .padding()
    .background(.black)
}
#endif
