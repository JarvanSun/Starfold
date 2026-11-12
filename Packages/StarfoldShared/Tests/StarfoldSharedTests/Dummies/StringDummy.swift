//
//  StringDummy.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension String {
    nonisolated static func dummyXboxTokenResponse(
        token: String,
        gamertag: String? = nil,
        xuid: String? = nil
    ) -> String {
        let gamertagClaim = gamertag.map { #","gtg":"\#($0)""# } ?? ""
        let xuidClaim = xuid.map { #","xid":"\#($0)""# } ?? ""
        return
            #"{"NotAfter":"2099-01-01T00:00:00Z","Token":"\#(token)","DisplayClaims":{"xui":[{"uhs":"123"\#(gamertagClaim)\#(xuidClaim)}]}}"#
    }

    nonisolated static func dummyStreamingLoginResponse(region: XboxEndpoint) -> String {
        """
        {"offeringSettings":{"regions":[{"name":"Default","baseUri":"\(region.rawValue)","isDefault":true}]},
         "market":"US","gsToken":"gs","durationInSeconds":14400}
        """
    }

    nonisolated static func dummyDeviceCodeResponse(
        userCode: String,
        expiresIn: Int,
        interval: Int
    ) -> String {
        """
        {"user_code":"\(userCode)","device_code":"dev-\(userCode)","verification_uri":"https://www.microsoft.com/link","expires_in":\(expiresIn),"interval":\(interval)}
        """
    }

    nonisolated static var dummyMicrosoftTokenResponse: String {
        #"{"access_token":"msa","refresh_token":"refresh","expires_in":3600}"#
    }

    nonisolated static var dummyProfileResponse: String {
        """
        {"profileUsers":[{"id":"2535","settings":[{"id":"Gamertag","value":"NovaPilot"},{"id":"ModernGamertag","value":"NovaPilot"},
         {"id":"Gamerscore","value":"5865"},{"id":"GameDisplayPicRaw","value":"https://images-eds.xboxlive.com/pic?x=1"}]}]}
        """
    }

    nonisolated static var dummyConsoleOn: String {
        #"{"results":[{"serverId":"X","deviceName":"Living room","consoleType":"XboxSeriesX","powerState":"On"}]}"#
    }

    nonisolated static var dummyConsoleInStandby: String {
        #"{"results":[{"serverId":"X","deviceName":"Living room","consoleType":"XboxSeriesX","powerState":"ConnectedStandby"}]}"#
    }

    nonisolated static var dummyPresencePlayingDiablo: String {
        #"{"devices":[{"type":"Scarlett","titles":[{"id":"200","name":"Diablo IV","placement":"Full","state":"Active"}]}]}"#
    }

    nonisolated static var dummyPresenceIdle: String {
        #"{"devices":[]}"#
    }

    nonisolated static var dummyHistoryDiablo: String {
        #"{"titles":[{"titleId":"200","name":"Diablo IV","displayImage":"https://img/d4","devices":["XboxSeries"]}]}"#
    }

    nonisolated static var dummyHistoryFortniteThenDiablo: String {
        #"{"titles":[{"titleId":"300","name":"Fortnite","displayImage":"https://img/fn","devices":["XboxSeries","PC"]},{"titleId":"200","name":"Diablo IV","displayImage":"https://img/d4","devices":["XboxSeries"]}]}"#
    }

    nonisolated static var dummyCloudTitles: String {
        """
        {"results":[
          {"titleId":"ALPHA","details":{"productId":"9AAA","hasEntitlement":true,"isFreeInStore":false,"supportedInputTypes":["Controller"],"userSubscriptions":["XGPULTIMATE"]}},
          {"titleId":"BRAVO","details":{"productId":"9BBB","hasEntitlement":false,"isFreeInStore":true,"supportedInputTypes":["Controller","MKB"]}},
          {"titleId":"CHARLIE","details":{"productId":"9CCC","hasEntitlement":false,"isFreeInStore":false,"supportedInputTypes":[]}}]}
        """
    }

    nonisolated static var dummyRecentCloudTitles: String {
        """
        {"results":[{"titleId":"BRAVO","details":{"productId":"9BBB","hasEntitlement":false,"isFreeInStore":true},
          "titleHistory":{"lastTimePlayed":"2026-09-20T10:00:00Z"}}]}
        """
    }

    nonisolated static var dummyCatalogProducts: String {
        """
        {"Products":{
          "9AAA":{"ProductTitle":"Zeta Quest","StoreId":"9AAA","PublisherName":"Studio One","Image_Tile":{"URL":"//img/a"}},
          "9BBB":{"ProductTitle":"Alpha Racer","StoreId":"9BBB","PublisherName":"Speed Co"}}}
        """
    }

    nonisolated static var dummyCuratedList: String {
        #"[{"title":"List"},{"id":"9aaa"},{"id":"9ZZZ"}]"#
    }
}
