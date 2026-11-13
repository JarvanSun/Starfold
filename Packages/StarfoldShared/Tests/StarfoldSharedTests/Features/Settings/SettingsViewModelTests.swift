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
        let settings = makeSettings(defaults: defaults)

        // When
        settings.consoleQuality = .fixed(.highest)

        // Then
        #expect(makeSettings(defaults: defaults).consoleQuality == .fixed(.highest))
    }

    @Test
    func qualityChoicesThenOfferAutomaticFirstAndEveryFixedQuality() {
        // Given
        let settings = makeSettings()

        // When
        let choices = settings.qualityChoices

        // Then
        #expect(choices == [.automatic, .fixed(.standard), .fixed(.high), .fixed(.highest)])
    }

    @Test
    func bitrateChoicesThenStartWithAutomaticAndRise() {
        // Given
        let settings = makeSettings()

        // When
        let choices = settings.bitrateChoices

        // Then
        #expect(choices.first.map(settings.isAutomatic(bitrate:)) == true)
        #expect(choices.dropFirst().allSatisfy { !settings.isAutomatic(bitrate: $0) })
        #expect(choices == choices.sorted())
    }

    @Test
    func gameLanguagesThenStartWithTheSystemLanguage() {
        // Given
        let settings = makeSettings()

        // When
        let languages = settings.gameLanguages

        // Then
        #expect(languages.first.map(settings.isSystem(gameLanguage:)) == true)
        #expect(Set(languages).count == languages.count)
        #expect(languages.contains("zh-CN"))
    }

    @Test
    func effectiveGameLanguageWhenSystemIsChosenThenIsALanguageAndRegion() {
        // Given
        let settings = makeSettings()

        // When
        settings.gameLanguage = settings.gameLanguages[0]

        // Then
        #expect(settings.effectiveGameLanguage.split(separator: "-").count == 2)
    }

    @Test
    func effectiveGameLanguageWhenOneIsChosenThenIsThatLanguage() {
        // Given
        let settings = makeSettings()

        // When
        settings.gameLanguage = "ja-JP"

        // Then
        #expect(settings.effectiveGameLanguage == "ja-JP")
    }

    @Test(arguments: [true, false])
    func canToneMapHDRThenFollowsTheDisplay(isHDRDisplayAvailable: Bool) {
        // Given
        let settings = makeSettings(
            picture: .init(
                canFit: true,
                canEnhance: true,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: { isHDRDisplayAvailable }
            )
        )

        // Then
        #expect(settings.canToneMapHDR == isHDRDisplayAvailable)
    }

    @Test
    func canToneMapHDRWhenPlatformHasNoChoiceThenIsFalse() {
        // Given
        let settings = makeSettings(
            picture: .init(
                canFit: false,
                canEnhance: false,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: nil
            )
        )

        // Then
        #expect(!settings.canToneMapHDR)
        #expect(!settings.canChoosePictureFit)
        #expect(!settings.canEnhancePicture)
    }

    @Test
    func playerNumberThenCountsFromOne() {
        // Given
        let settings = makeSettings()
        let controller = ConnectedController(
            id: ObjectIdentifier(NSObject()),
            slot: 0,
            name: "Pad",
            batteryLevel: 0
        )

        // Then
        #expect(settings.playerNumber(of: controller) == 1)
        #expect(settings.batteryLevel(of: controller) == nil)
    }

    @Test
    func isControllerMissingWhenNoneIsConnectedThenIsTrue() {
        // Given
        let settings = makeSettings()

        // Then
        #expect(settings.isControllerMissing)
        #expect(settings.connectedControllers.isEmpty)
    }

    @Test
    func titleOfBitrateThenNamesAutomaticAndEveryFixedBitrateDifferently() {
        // Given
        let settings = makeSettings()

        // When
        let titles = settings.bitrateChoices.map {
            String(localized: settings.title(ofBitrate: $0))
        }

        // Then
        #expect(titles.first == String(localized: "settings.bitrate.automatic", bundle: .module))
        #expect(Set(titles).count == titles.count)
    }

    @Test
    func nameOfGameLanguageWhenSystemThenSaysItFollowsTheSystem() {
        // Given
        let settings = makeSettings()

        // When
        let name = settings.name(ofGameLanguage: settings.gameLanguages[0])

        // Then
        #expect(name == String(localized: "settings.gameLanguage.system", bundle: .module))
    }

    @Test
    func nameOfGameLanguageWhenOneIsChosenThenIsThatLanguagesName() {
        // Given
        let settings = makeSettings()

        // Then
        #expect(settings.name(ofGameLanguage: "ja-JP") != "ja-JP")
        #expect(settings.name(ofGameLanguage: "ja-JP") != settings.name(ofGameLanguage: ""))
    }

    @Test
    func accountChoicesThenListEveryAccountAndMarkTheActiveOne() {
        // Given
        session.accounts = [
            .init(id: "1111", gamertag: "First"), .init(id: "2222", gamertag: "Second"),
        ]
        session.activeAccountID = "2222"
        let settings = makeSettings()

        // Then
        #expect(
            settings.accountChoices == [
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
        await harness.app.restore()

        // Then
        #expect(harness.app.settings.accountChoices.map(\.id) == ["2535"])
        #expect(harness.app.settings.accountChoices.first?.isActive == true)
    }

    @Test
    func switchAccountThenSwitchesToTheChosenAccount() async {
        // Given
        let settings = makeSettings()

        // When
        await settings.switchAccount(to: .init(id: "1111", gamertag: "First", isActive: false))

        // Then
        #expect(session.switchedAccountIDs == ["1111"])
    }

    @Test
    func signOutSubjectWhenSignedInThenIsTheGamertag() {
        // Given
        session.signedInGamertag = "NovaPilot"
        let settings = makeSettings()

        // Then
        #expect(settings.signOutSubject == "NovaPilot")
    }

    @Test
    func signOutSubjectWhenGamertagIsUnknownThenIsTheAppName() {
        // Given
        let settings = makeSettings()

        // Then
        #expect(settings.signOutSubject == AppInfo().displayName)
    }

    @Test
    func signOutThenSignsOutOfTheSession() {
        // Given
        let settings = makeSettings()

        // When
        settings.signOut()

        // Then
        #expect(session.signOutCount == 1)
    }

    @Test(arguments: [true, false])
    func needsStreamRestartThenFollowsTheRunningStream(needsRestart: Bool) {
        // Given
        session.needsStreamRestartForSettings = needsRestart
        let settings = makeSettings()

        // Then
        #expect(settings.needsStreamRestart == needsRestart)
    }

    @Test
    func restartStreamThenRestartsTheRunningStream() async {
        // Given
        let settings = makeSettings()

        // When
        await settings.restartStream()

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
        let settings = SettingsViewModel(
            preferences: .init(defaults: defaults),
            controllers: ControllerHub(routing: .direct),
            platform: .init(
                controllerRouting: .direct,
                picture: picture,
                overlays: .init(statisticsRows: [], controlsHideDelay: nil),
                touch: nil
            ),
            network: NetworkPathStub()
        )
        settings.session = session
        return settings
    }
}
