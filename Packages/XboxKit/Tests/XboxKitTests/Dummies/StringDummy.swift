//
//  StringDummy.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension String {
    nonisolated static func dummyDeviceCodeResponse(userCode: String = "ABCD1234") -> String {
        """
        {"user_code":"\(userCode)","device_code":"dev","verification_uri":"https://www.microsoft.com/link","expires_in":900,"interval":0}
        """
    }

    nonisolated static func dummyXboxTokenResponse(
        token: String,
        notAfter: String = "2030-01-01T00:00:00.1234567Z",
        gamertag: String? = nil,
        xuid: String? = nil
    ) -> String {
        let gamertagClaim = gamertag.map { #","gtg":"\#($0)""# } ?? ""
        let xuidClaim = xuid.map { #","xid":"\#($0)""# } ?? ""
        return """
            {"IssueInstant":"2026-09-28T10:00:00.1234567Z","NotAfter":"\(notAfter)","Token":"\(token)",
             "DisplayClaims":{"xui":[{"uhs":"123"\(gamertagClaim)\(xuidClaim)}]}}
            """
    }

    nonisolated static func dummyStreamingLoginResponse(token: String) -> String {
        """
        {"offeringSettings":{"allowRegionSelection":false,"regions":[
          {"name":"WestUS2","baseUri":"https://wus2.core.gssv-play-prodxhome.xboxlive.com","networkTestHostname":null,"isDefault":false,"fallbackPriority":1},
          {"name":"UkSouth","baseUri":"https://uks.core.gssv-play-prodxhome.xboxlive.com","networkTestHostname":null,"isDefault":true,"fallbackPriority":-1}]},
         "market":"GB","gsToken":"\(token)","tokenType":"bearer","durationInSeconds":14400}
        """
    }

    nonisolated static func dummySessionState(
        _ state: String,
        code: String? = nil,
        message: String? = nil
    ) -> String {
        let details =
            code.map { #"{"code":"\#($0)","message":"\#(message ?? "")"}"# }
            ?? #"{"code":null,"message":null}"#
        return #"{"state":"\#(state)","errorDetails":\#(details)}"#
    }

    nonisolated static var dummyTitleHistory: String {
        """
        {"titles":[
          {"titleId":"100","name":"Phone Game","displayImage":"http://store-images.s-microsoft.com/phone","devices":["Mobile"]},
          {"titleId":"200","name":"Diablo IV","displayImage":"http://store-images.s-microsoft.com/tile","devices":["XboxSeries","PC"],
           "images":[{"url":"http://store-images.s-microsoft.com/box","type":"BoxArt"},
                     {"url":"http://store-images.s-microsoft.com/hero","type":"SuperHeroArt"}]}]}
        """
    }

    nonisolated static var dummyFortniteProducts: String {
        #"{"Products":{"BT5P2X999VH2":{"ProductTitle":"Fortnite","StoreId":"BT5P2X999VH2"}}}"#
    }
}
