//
//  SettingsViewModelTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct SettingsViewModelTests {
    private let session = SessionControllingStub()

    @Test
    func consoleQualityWhenChangedThenIsSavedForTheNextLaunch() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        let settingsViewModel = makeSettings(defaults: defaults)

        // When
        settingsViewModel.consoleQuality = .fixed(.highest)

        // Then
        #expect(makeSettings(defaults: defaults).consoleQuality == .fixed(.highest))
    }

    @Test
    func qualityChoicesThenOfferAutomaticFirstAndEveryFixedQuality() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        let choices = settingsViewModel.qualityChoices

        // Then
        #expect(choices == [.automatic, .fixed(.standard), .fixed(.high), .fixed(.highest)])
    }

    @Test
    func bitrateChoicesThenStartWithAutomaticAndRise() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        let choices = settingsViewModel.bitrateChoices

        // Then
        #expect(choices.first.map(settingsViewModel.isAutomatic(bitrate:)) == true)
        #expect(choices.dropFirst().allSatisfy { !settingsViewModel.isAutomatic(bitrate: $0) })
        #expect(choices == choices.sorted())
    }

    @Test
    func gameLanguagesThenStartWithTheSystemLanguage() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        let languages = settingsViewModel.gameLanguages

        // Then
        #expect(languages.first.map(settingsViewModel.isSystem(gameLanguage:)) == true)
        #expect(Set(languages).count == languages.count)
        #expect(languages.contains("zh-CN"))
    }

    @Test
    func effectiveGameLanguageWhenSystemIsChosenThenIsALanguageAndRegion() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        settingsViewModel.gameLanguage = settingsViewModel.gameLanguages[0]

        // Then
        #expect(settingsViewModel.effectiveGameLanguage.split(separator: "-").count == 2)
    }

    @Test
    func effectiveGameLanguageWhenOneIsChosenThenIsThatLanguage() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        settingsViewModel.gameLanguage = "ja-JP"

        // Then
        #expect(settingsViewModel.effectiveGameLanguage == "ja-JP")
    }

    @Test
    func editTouchLayoutThenKeepsOneEditorUntilEditingFinishes() throws {
        // Given
        let settingsViewModel = makeSettings()

        // When
        settingsViewModel.editTouchLayout()

        // Then
        let editor = try #require(settingsViewModel.touchLayoutEditorViewModel)
        #expect(settingsViewModel.touchLayoutEditorViewModel === editor)
        settingsViewModel.finishEditingTouchLayout()
        #expect(settingsViewModel.touchLayoutEditorViewModel == nil)
    }

    @Test(arguments: [true, false])
    func canToneMapHDRThenFollowsTheDisplay(isHDRDisplayAvailable: Bool) {
        // Given
        let settingsViewModel = makeSettings(
            picture: .init(
                canFit: true,
                canEnhance: true,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: { isHDRDisplayAvailable }
            )
        )

        // Then
        #expect(settingsViewModel.canToneMapHDR == isHDRDisplayAvailable)
    }

    @Test
    func canToneMapHDRWhenPlatformHasNoChoiceThenIsFalse() {
        // Given
        let settingsViewModel = makeSettings(
            picture: .init(
                canFit: false,
                canEnhance: false,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: nil
            )
        )

        // Then
        #expect(!settingsViewModel.canToneMapHDR)
        #expect(!settingsViewModel.canChoosePictureFit)
        #expect(!settingsViewModel.canEnhancePicture)
    }

    @Test
    func playerNumberThenCountsFromOne() {
        // Given
        let settingsViewModel = makeSettings()
        let controller = ConnectedController(
            id: ObjectIdentifier(NSObject()),
            slot: 0,
            name: "Pad",
            batteryLevel: 0
        )

        // Then
        #expect(settingsViewModel.playerNumber(of: controller) == 1)
        #expect(settingsViewModel.batteryLevel(of: controller) == nil)
    }

    @Test(
        .disabled(
            if: ControllerAvailability().hasConnectedController,
            "needs no connected controller"
        )
    )
    func isControllerMissingWhenNoneIsConnectedThenIsTrue() {
        // Given
        let settingsViewModel = makeSettings()

        // Then
        #expect(settingsViewModel.isControllerMissing)
        #expect(settingsViewModel.connectedControllers.isEmpty)
    }

    @Test
    func titleOfBitrateThenNamesAutomaticAndEveryFixedBitrateDifferently() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        let titles = settingsViewModel.bitrateChoices.map {
            String(localized: settingsViewModel.title(ofBitrate: $0))
        }

        // Then
        #expect(titles.first == String(localized: "settings.bitrate.automatic", bundle: .module))
        #expect(Set(titles).count == titles.count)
    }

    @Test
    func nameOfGameLanguageWhenSystemThenSaysItFollowsTheSystem() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        let name = settingsViewModel.name(ofGameLanguage: settingsViewModel.gameLanguages[0])

        // Then
        #expect(name == String(localized: "settings.gameLanguage.system", bundle: .module))
    }

    @Test
    func nameOfGameLanguageWhenOneIsChosenThenIsThatLanguagesName() {
        // Given
        let settingsViewModel = makeSettings()

        // Then
        #expect(settingsViewModel.name(ofGameLanguage: "ja-JP") != "ja-JP")
        #expect(
            settingsViewModel.name(ofGameLanguage: "ja-JP")
                != settingsViewModel.name(ofGameLanguage: "")
        )
    }

    @Test
    func accountChoicesThenListEveryAccountAndMarkTheActiveOne() {
        // Given
        session.accounts = [
            .init(id: "1111", gamertag: "First"), .init(id: "2222", gamertag: "Second"),
        ]
        session.activeAccountID = "2222"
        let settingsViewModel = makeSettings()

        // Then
        #expect(
            settingsViewModel.accountChoices == [
                .init(id: "1111", gamertag: "First", isActive: false),
                .init(id: "2222", gamertag: "Second", isActive: true),
            ]
        )
    }

    @Test
    func accountChoicesWhenAppRestoresAccountsThenComeFromTheApp() async {
        // Given
        let harness = AppHarness()
        harness.accountService.savedAccounts = [.dummy(id: "2535", gamertag: "NovaPilot")]

        // When
        await harness.appViewModel.restore()

        // Then
        #expect(harness.appViewModel.settingsViewModel.accountChoices.map(\.id) == ["2535"])
        #expect(harness.appViewModel.settingsViewModel.accountChoices.first?.isActive == true)
    }

    @Test
    func switchAccountThenSwitchesToTheChosenAccount() async {
        // Given
        let settingsViewModel = makeSettings()

        // When
        await settingsViewModel.switchAccount(
            to: .init(id: "1111", gamertag: "First", isActive: false)
        )

        // Then
        #expect(session.switchedAccountIDs == ["1111"])
    }

    @Test
    func signOutSubjectWhenSignedInThenIsTheGamertag() {
        // Given
        session.signedInGamertag = "NovaPilot"
        let settingsViewModel = makeSettings()

        // Then
        #expect(settingsViewModel.signOutSubject == "NovaPilot")
    }

    @Test
    func signOutSubjectWhenGamertagIsUnknownThenIsTheAppName() {
        // Given
        let settingsViewModel = makeSettings()

        // Then
        #expect(settingsViewModel.signOutSubject == AppInfo().displayName)
    }

    @Test
    func signOutThenSignsOutOfTheSession() {
        // Given
        let settingsViewModel = makeSettings()

        // When
        settingsViewModel.signOut()

        // Then
        #expect(session.signOutCount == 1)
    }

    @Test(arguments: [true, false])
    func needsStreamRestartThenFollowsTheRunningStream(needsRestart: Bool) {
        // Given
        session.needsStreamRestartForSettings = needsRestart
        let settingsViewModel = makeSettings()

        // Then
        #expect(settingsViewModel.needsStreamRestart == needsRestart)
    }

    @Test
    func restartStreamThenRestartsTheRunningStream() async {
        // Given
        let settingsViewModel = makeSettings()

        // When
        await settingsViewModel.restartStream()

        // Then
        #expect(session.streamRestartCount == 1)
    }
}

private extension SettingsViewModelTests {
    func makeSettings(
        defaults: UserDefaults = .dummyEmpty,
        picture: PictureCapabilities = .init(
            canFit: true,
            canEnhance: true,
            shouldKeepLastFrame: false,
            isHDRDisplayAvailable: nil
        )
    ) -> SettingsViewModel {
        let settingsViewModel = SettingsViewModel(
            preferences: .init(defaults: defaults),
            controllerHub: ControllerHub(controllerRouting: .direct),
            streamPlatform: .init(
                controllerRouting: .direct,
                pictureCapabilities: picture,
                overlays: .init(statisticsRows: [], controlsHideDelay: nil),
                touchPlatform: nil
            ),
            networkPath: NetworkPathStub()
        )
        settingsViewModel.sessionController = session
        return settingsViewModel
    }
}
