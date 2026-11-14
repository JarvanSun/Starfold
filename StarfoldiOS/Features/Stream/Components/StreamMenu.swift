//
//  StreamMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit
import SwiftUI

struct StreamMenu: View {
    @Environment(\.dimensions) private var dimensions
    @Bindable var settingsViewModel: SettingsViewModel

    let streamViewModel: StreamViewModel

    let onEditTouchControls: () -> Void
    let onDisconnect: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceLarge) {
            actions

            pictureModePicker

            bufferPicker

            Button {
                onEditTouchControls()
            } label: {
                Label(String(localized: "stream.menu.editTouchControls"), systemImage: "hand.tap")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
        }
        .padding(dimensions.spaceLarge)
        .frame(maxWidth: dimensions.streamMenuWidth)
        .glassEffect(in: .rect(cornerRadius: dimensions.cornerRadiusXLarge))
        .environment(\.colorScheme, .dark)
    }

    private var actions: some View {
        HStack(spacing: dimensions.spaceSmall) {
            actionButton("stream.menu.guide", symbol: "xbox.logo") { streamViewModel.openGuide() }

            Toggle(isOn: $settingsViewModel.shouldShowStatistics) {
                actionLabel("stream.menu.statistics", symbol: "chart.bar.fill")
            }
            .toggleStyle(.button)
            .buttonStyle(.glass)

            actionButton("stream.menu.disconnect", symbol: "xmark", role: .destructive) {
                onDisconnect()
            }
        }
    }

    private func actionButton(
        _ title: LocalizedStringResource,
        symbol: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role) {
            action()
        } label: {
            actionLabel(title, symbol: symbol)
        }
        .buttonStyle(.glass)
    }

    private func actionLabel(_ title: LocalizedStringResource, symbol: String) -> some View {
        VStack(spacing: dimensions.spaceXSmall) {
            Image(systemName: symbol)
                .font(.title3)

            Text(title)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: dimensions.streamMenuActionHeight)
    }

    private var pictureModePicker: some View {
        LabeledContent(String(localized: "stream.menu.pictureMode")) {
            Picker(
                String(localized: "stream.menu.pictureMode"),
                selection: $settingsViewModel.pictureFit
            ) {
                ForEach(settingsViewModel.pictureFits, id: \.self) { fit in
                    Text(fit.title).tag(fit)
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
    }

    private var bufferPicker: some View {
        LabeledContent(String(localized: "stream.menu.buffer")) {
            Picker(
                String(localized: "stream.menu.buffer"),
                selection: $settingsViewModel.pacingMode
            ) {
                ForEach(settingsViewModel.pacingModes, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
    }
}

#if DEBUG
#Preview {
    let preview = PreviewObjectPool.cloudStreamPreview(phase: .streaming)

    StreamMenu(
        settingsViewModel: preview.settings,
        streamViewModel: preview.stream,
        onEditTouchControls: {},
        onDisconnect: {}
    )
    .padding()
    .background(.black)
}
#endif
