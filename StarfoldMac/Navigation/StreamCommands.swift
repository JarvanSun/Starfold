//
//  StreamCommands.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppKit
import StarfoldShared
import StreamKit
import SwiftUI

struct StreamCommands: Commands {
    @FocusedValue(\.activeStream) private var stream
    @FocusedValue(\.activePictureInPicture) private var pictureInPicture
    @Bindable private var settings: SettingsViewModel

    private let app: AppViewModel

    private var isStreaming: Bool {
        stream?.isStreaming == true
    }

    init(app: AppViewModel) {
        self.app = app
        settings = app.settings
    }

    var body: some Commands {
        CommandMenu(String(localized: "menu.stream.title")) {
            openGuideButton

            statisticsToggle

            copyStatisticsButton

            upscalingToggle

            if settings.canToneMapHDR {
                toneMappingToggle
            }

            pictureFitMenu

            pacingMenu

            keyboardControllerToggle

            Divider()

            pictureInPictureButton

            freshPictureButton
        }

        CommandGroup(after: .sidebar) {
            refreshLibraryButton
        }
    }

    private var openGuideButton: some View {
        Button(String(localized: "menu.stream.openGuide")) {
            stream?.openGuide()
        }
        .keyboardShortcut("g")
        .disabled(!isStreaming)
    }

    private var statisticsToggle: some View {
        Toggle(
            String(localized: "menu.stream.showStatistics"),
            isOn: $settings.shouldShowStatistics
        )
        .keyboardShortcut("i")
    }

    private var copyStatisticsButton: some View {
        Button(String(localized: "menu.stream.copyStatistics")) { copyStatistics() }
            .keyboardShortcut("c", modifiers: [.command, .option])
            .disabled(!isStreaming)
    }

    private func copyStatistics() {
        guard let stream else { return }

        let report = stream.statisticsReport(device: device)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report, forType: .string)
    }

    private var device: String {
        "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    private var upscalingToggle: some View {
        Toggle(String(localized: "menu.stream.upscaling"), isOn: $settings.isUpscalingEnabled)
    }

    private var toneMappingToggle: some View {
        Toggle(
            String(localized: "menu.stream.toneMapping"),
            isOn: $settings.isHDRToneMappingEnabled
        )
    }

    private var pictureFitMenu: some View {
        Menu(String(localized: "menu.stream.pictureMode")) {
            ForEach(Array(settings.pictureFits.enumerated()), id: \.element) { index, fit in
                Toggle(fit.title, isOn: isSelected(fit))
                    .keyboardShortcut(shortcutKey(at: index), modifiers: [.command, .control])
            }
        }
    }

    private func isSelected(_ fit: PictureFit) -> Binding<Bool> {
        .init(
            get: { settings.pictureFit == fit },
            set: { isOn in
                if isOn {
                    settings.pictureFit = fit
                }
            }
        )
    }

    private var pacingMenu: some View {
        Menu(String(localized: "menu.stream.buffer")) {
            ForEach(Array(settings.pacingModes.enumerated()), id: \.element) { index, mode in
                Toggle(mode.title, isOn: isSelected(mode))
                    .keyboardShortcut(shortcutKey(at: index), modifiers: [.command, .option])
            }
        }
    }

    private func isSelected(_ mode: PacingMode) -> Binding<Bool> {
        .init(
            get: { settings.pacingMode == mode },
            set: { isOn in
                if isOn {
                    settings.pacingMode = mode
                }
            }
        )
    }

    private func shortcutKey(at index: Int) -> KeyEquivalent {
        .init(Character("\(index + 1)"))
    }

    private var keyboardControllerToggle: some View {
        Toggle(
            String(localized: "menu.stream.keyboardAsController"),
            isOn: $settings.isKeyboardControllerEnabled
        )
        .keyboardShortcut("k", modifiers: [.command, .shift])
    }

    private var pictureInPictureButton: some View {
        Button(String(localized: "menu.stream.pictureInPicture")) {
            pictureInPicture?.toggle()
        }
        .keyboardShortcut("p", modifiers: [.command, .option])
        .disabled(!canTogglePictureInPicture)
    }

    private var canTogglePictureInPicture: Bool {
        isStreaming && pictureInPicture?.isPossible == true
    }

    private var freshPictureButton: some View {
        Button(String(localized: "menu.stream.requestFreshPicture")) {
            stream?.requestKeyframe()
        }
        .keyboardShortcut("r", modifiers: [.command, .option])
        .disabled(!isStreaming)
    }

    private var refreshLibraryButton: some View {
        Button(String(localized: "menu.view.refreshLibrary")) { refreshLibrary() }
            .keyboardShortcut("r")
            .disabled(app.library == nil)
    }

    private func refreshLibrary() {
        Task { await app.library?.refresh() }
    }
}
