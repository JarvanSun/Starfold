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
    @Bindable var settingsViewModel: SettingsViewModel
    @Bindable var streamViewModel: StreamViewModel

    var body: some View {
        Menu {
            upscalingToggle

            if settingsViewModel.canToneMapHDR {
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

    private var upscalingToggle: some View {
        Toggle(
            String(localized: "stream.controlBar.picture.upscaling"),
            isOn: $settingsViewModel.isUpscalingEnabled
        )
    }

    private var toneMappingToggle: some View {
        Toggle(
            String(localized: "stream.controlBar.picture.toneMapping"),
            isOn: $settingsViewModel.isHDRToneMappingEnabled
        )
    }

    private var pictureFitPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.pictureMode"),
            selection: $settingsViewModel.pictureFit
        ) {
            ForEach(settingsViewModel.pictureFits, id: \.self) { fit in
                Text(fit.title).tag(fit)
            }
        }
    }

    private var sharpeningPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.sharpening.title"),
            selection: $streamViewModel.sharpeningLevel
        ) {
            ForEach(streamViewModel.sharpeningLevels, id: \.self) { level in
                Text(level.title).tag(level)
            }
        }
    }

    private var pacingPicker: some View {
        Picker(
            String(localized: "stream.controlBar.picture.buffer"),
            selection: $settingsViewModel.pacingMode
        ) {
            ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                Text(mode.title).tag(mode)
            }
        }
    }
}

#if DEBUG
#Preview {
    let preview = PreviewObjectPool.streamPreview(phase: .streaming)

    PictureMenu(
        settingsViewModel: preview.settingsViewModel,
        streamViewModel: preview.streamViewModel
    )
    .padding()
    .background(.black)
}
#endif
