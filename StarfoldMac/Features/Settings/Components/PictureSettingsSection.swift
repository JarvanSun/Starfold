//
//  PictureSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettingsSection: View {
    @Bindable var settingsViewModel: SettingsViewModel

    var body: some View {
        Section {
            upscalingToggle

            sharpeningSlider

            if settingsViewModel.canToneMapHDR {
                toneMappingToggle
            }

            pictureFitPicker

            Toggle(
                String(localized: "settings.picture.statistics"),
                isOn: $settingsViewModel.shouldShowStatistics
            )
        }
    }

    private var upscalingToggle: some View {
        Toggle(isOn: $settingsViewModel.isUpscalingEnabled) {
            Text("settings.picture.upscaling.title")

            Text("settings.picture.upscaling.detail")
        }
    }

    private var sharpeningSlider: some View {
        LabeledContent {
            Slider(value: $settingsViewModel.sharpening, in: 0...1) {
                EmptyView()
            } minimumValueLabel: {
                Text("settings.picture.sharpening.minimum")
            } maximumValueLabel: {
                Text("settings.picture.sharpening.maximum")
            }
        } label: {
            Text("settings.picture.sharpening.title")

            Text("settings.picture.sharpening.detail")
        }
    }

    private var toneMappingToggle: some View {
        Toggle(isOn: $settingsViewModel.isHDRToneMappingEnabled) {
            Text("settings.picture.toneMapping.title")

            Text("settings.picture.toneMapping.detail")
        }
    }

    private var pictureFitPicker: some View {
        Picker(
            String(localized: "settings.picture.pictureMode"),
            selection: $settingsViewModel.pictureFit
        ) {
            ForEach(settingsViewModel.pictureFits, id: \.self) { fit in
                Text(fit.title).tag(fit)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        PictureSettingsSection(settingsViewModel: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
