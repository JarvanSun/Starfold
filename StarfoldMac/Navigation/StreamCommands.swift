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
    @FocusedValue(\.activeStreamViewModel) private var streamViewModel
    @FocusedValue(\.activePictureInPicture) private var pictureInPicture
    @Bindable private var settingsViewModel: SettingsViewModel

    private let appViewModel: AppViewModel

    private var isStreaming: Bool {
        streamViewModel?.isStreaming == true
    }

    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        settingsViewModel = appViewModel.settingsViewModel
    }

    var body: some Commands {
        CommandMenu(String(localized: "menu.stream.title")) {
            openGuideButton

            statisticsToggle

            copyStatisticsButton

            upscalingToggle

            if settingsViewModel.canToneMapHDR {
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
            streamViewModel?.openGuide()
        }
        .keyboardShortcut("g")
        .disabled(!isStreaming)
    }

    private var statisticsToggle: some View {
        Toggle(
            String(localized: "menu.stream.showStatistics"),
            isOn: $settingsViewModel.shouldShowStatistics
        )
        .keyboardShortcut("i")
    }

    private var copyStatisticsButton: some View {
        Button(String(localized: "menu.stream.copyStatistics")) { copyStatistics() }
            .keyboardShortcut("c", modifiers: [.command, .option])
            .disabled(!isStreaming)
    }

    private func copyStatistics() {
        guard let streamViewModel else { return }

        let report = streamViewModel.statisticsReport(device: device)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report, forType: .string)
    }

    private var device: String {
        "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }

    private var upscalingToggle: some View {
        Toggle(
            String(localized: "menu.stream.upscaling"),
            isOn: $settingsViewModel.isUpscalingEnabled
        )
    }

    private var toneMappingToggle: some View {
        Toggle(
            String(localized: "menu.stream.toneMapping"),
            isOn: $settingsViewModel.isHDRToneMappingEnabled
        )
    }

    private var pictureFitMenu: some View {
        Menu(String(localized: "menu.stream.pictureMode")) {
            ForEach(Array(settingsViewModel.pictureFits.enumerated()), id: \.element) {
                index,
                fit in
                Toggle(fit.title, isOn: isSelected(fit))
                    .keyboardShortcut(shortcutKey(at: index), modifiers: [.command, .control])
            }
        }
    }

    private func shortcutKey(at index: Int) -> KeyEquivalent {
        .init(Character("\(index + 1)"))
    }

    private func isSelected(_ fit: PictureFit) -> Binding<Bool> {
        .init(
            get: { settingsViewModel.pictureFit == fit },
            set: { isOn in
                if isOn {
                    settingsViewModel.pictureFit = fit
                }
            }
        )
    }

    private var pacingMenu: some View {
        Menu(String(localized: "menu.stream.buffer")) {
            ForEach(Array(settingsViewModel.pacingModes.enumerated()), id: \.element) {
                index,
                mode in
                Toggle(mode.title, isOn: isSelected(mode))
                    .keyboardShortcut(shortcutKey(at: index), modifiers: [.command, .option])
            }
        }
    }

    private func isSelected(_ mode: PacingMode) -> Binding<Bool> {
        .init(
            get: { settingsViewModel.pacingMode == mode },
            set: { isOn in
                if isOn {
                    settingsViewModel.pacingMode = mode
                }
            }
        )
    }

    private var keyboardControllerToggle: some View {
        Toggle(
            String(localized: "menu.stream.keyboardAsController"),
            isOn: $settingsViewModel.isKeyboardControllerEnabled
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
            streamViewModel?.requestKeyframe()
        }
        .keyboardShortcut("r", modifiers: [.command, .option])
        .disabled(!isStreaming)
    }

    private var refreshLibraryButton: some View {
        Button(String(localized: "menu.view.refreshLibrary")) { refreshLibrary() }
            .keyboardShortcut("r")
            .disabled(appViewModel.libraryViewModel == nil)
    }

    private func refreshLibrary() {
        Task { await appViewModel.libraryViewModel?.refresh() }
    }
}
