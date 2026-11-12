//
//  PictureSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct PictureSettingsSection: View {
    @Bindable var settings: SettingsViewModel

    var body: some View {
        Section {
            upscalingToggle

            sharpeningSlider

            if settings.canToneMapHDR {
                toneMappingToggle
            }

            pictureFitPicker

            Toggle(
                String(localized: "settings.picture.statistics"),
                isOn: $settings.shouldShowStatistics
            )
        }
    }
}

private extension PictureSettingsSection {
    var upscalingToggle: some View {
        Toggle(isOn: $settings.isUpscalingEnabled) {
            Text("settings.picture.upscaling.title")

            Text("settings.picture.upscaling.detail")
        }
    }

    var sharpeningSlider: some View {
        LabeledContent {
            Slider(value: $settings.sharpening, in: 0...1) {
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

    var toneMappingToggle: some View {
        Toggle(isOn: $settings.isHDRToneMappingEnabled) {
            Text("settings.picture.toneMapping.title")

            Text("settings.picture.toneMapping.detail")
        }
    }

    var pictureFitPicker: some View {
        Picker(String(localized: "settings.picture.pictureMode"), selection: $settings.pictureFit) {
            ForEach(settings.pictureFits, id: \.self) { fit in
                Text(fit.title).tag(fit)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        PictureSettingsSection(settings: PreviewObjectPool.settingsViewModel)
    }
    .formStyle(.grouped)
}
#endif
