//
//  StringDummy.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension String {
    static var dummyClientID: String {
        "00000000-0000-4000-8000-000000000000"
    }

    static func dummyDeviceCodeResponse(userCode: String = "ABCD1234") -> String {
        """
        {"user_code":"\(userCode)","device_code":"dev","verification_uri":"https://www.microsoft.com/link","expires_in":900,"interval":0}
        """
    }

    static func dummyXboxTokenResponse(
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

    static func dummyStreamingLoginResponse(token: String) -> String {
        """
        {"offeringSettings":{"allowRegionSelection":false,"regions":[
          {"name":"WestUS2","baseUri":"https://wus2.core.gssv-play-prodxhome.xboxlive.com","networkTestHostname":null,"isDefault":false,"fallbackPriority":1},
          {"name":"UkSouth","baseUri":"https://uks.core.gssv-play-prodxhome.xboxlive.com","networkTestHostname":null,"isDefault":true,"fallbackPriority":-1}]},
         "market":"GB","gsToken":"\(token)","tokenType":"bearer","durationInSeconds":14400}
        """
    }

    static func dummySessionState(
        _ state: String,
        code: String? = nil,
        message: String? = nil
    ) -> String {
        let details =
            code.map { #"{"code":"\#($0)","message":"\#(message ?? "")"}"# }
            ?? #"{"code":null,"message":null}"#
        return #"{"state":"\#(state)","errorDetails":\#(details)}"#
    }

    static var dummyTitleHistory: String {
        """
        {"titles":[
          {"titleId":"100","name":"Phone Game","displayImage":"http://store-images.s-microsoft.com/phone","devices":["Mobile"]},
          {"titleId":"200","name":"Diablo IV","displayImage":"http://store-images.s-microsoft.com/tile","devices":["XboxSeries","PC"],
           "images":[{"url":"http://store-images.s-microsoft.com/box","type":"BoxArt"},
                     {"url":"http://store-images.s-microsoft.com/hero","type":"SuperHeroArt"}]}]}
        """
    }

    static var dummyFortniteProducts: String {
        #"{"Products":{"BT5P2X999VH2":{"ProductTitle":"Fortnite","StoreId":"BT5P2X999VH2"}}}"#
    }

    static var dummyStandardControllerLayout: String {
        """
            {"$schema":"https://raw.githubusercontent.com/microsoft/xbox-game-streaming-tools/master/touch-adaptation-kit/schemas/layout/v3.1/layout.json",
            "content":{"left":{"inner":[{"type":"joystick","expand":false,
            "axis":{"input":"axisXY","output":"leftJoystick","deadzone":{"threshold":0.05,
            "radial":true}}}],"outer":[null,null,[{"type":"directionalPad"}],
            {"type":"button","action":"leftThumb"},null,{"type":"button","action":"leftTrigger"},
            {"type":"button","action":"leftBumper"}]},"right":{"inner":[{"type":"button",
            "action":"gamepadY"},{"type":"button","action":"gamepadB"},{"type":"button",
            "action":"gamepadA"},{"type":"button","action":"gamepadX"}],"outer":[{"type":"button",
            "action":"rightBumper"},{"type":"button","action":"rightTrigger"},
            null,{"type":"button","action":"rightThumb"},[{"type":"joystick",
            "axis":{"input":"axisXY","output":"rightJoystick","deadzone":{"threshold":0.05,
            "radial":true}}}]]},"upper":{"right":[{"type":"button","action":"menu"},
            {"type":"button","action":"view"}]}}}
        """
    }

    static var dummyFirstPersonShooterLayout: String {
        """
            {"$schema":"https://raw.githubusercontent.com/microsoft/xbox-game-streaming-tools/master/touch-adaptation-kit/schemas/layout/v3.1/layout.json",
            "content":{"left":{"inner":[{"type":"joystick","axis":{"input":"axisXY",
            "output":"leftJoystick"},"styles":{"default":{"knob":{"faceImage":{"type":"icon",
            "value":"walk"}}}}}]},"right":{"inner":[{"type":"touchpad","axis":[{"input":"axisX",
            "output":"relativeMouseX","sensitivity":5},{"input":"axisY","output":"relativeMouseY",
            "sensitivity":2.5}],"styles":{"default":{"faceImage":{"type":"icon",
            "value":"look"}}}}],"outer":[[{"type":"button","action":"leftTrigger",
            "toggle":true,"styles":{"default":{"faceImage":{"type":"icon",
            "value":"aim"}}}},null],{"type":"button","action":"rightThumb",
            "styles":{"default":{"faceImage":{"type":"icon","value":"crouch"}}}},
            {"type":"button","action":"gamepadA","styles":{"default":{"faceImage":{"type":"icon",
            "value":"jump"}}}},[{"type":"touchpad","axis":{"input":"axisXY",
            "output":"rightJoystick","deadzone":{"threshold":0.1,"radial":true}},
            "renderAsButton":true,"action":["rightTrigger","leftTrigger"],
            "styles":{"default":{"faceImage":{"type":"icon","value":"fire"}}}},
            {"type":"button","action":"gamepadB","styles":{"default":{"faceImage":{"type":"icon",
            "value":"punch"}}}},{"type":"button","action":"leftBumper","styles":{"default":{"faceImage":{"type":"icon",
            "value":"grenade"}}}}],{"type":"button","action":"gamepadX","styles":{"default":{"faceImage":{"type":"icon",
            "value":"interact"}}}},{"type":"button","action":"gamepadY","styles":{"default":{"faceImage":{"type":"icon",
            "value":"weaponSelect"}}}}]},"upper":{"right":[{"type":"button",
            "action":"menu"},{"type":"button","action":"view"}]},"sensors":[{"type":"gyroscope",
            "axis":{"input":"axisXY","output":"relativeMouse","sensitivity":8}}]}}
        """
    }

    static var dummyLayeredLayout: String {
        """
        {"content":{
          "left":{"inner":[{"$ref":"#/definitions/moveStick"}]},
          "right":{"inner":[
            {"type":"button","action":{"type":"layer","target":"WeaponLayer"},
             "visible":{"$ref":"../../context.json#/state/canSwitchWeapons"}},
            {"type":"button","action":[{"type":"turbo","action":"gamepadA","interval":120}],
             "pullAction":{"type":"segmented","items":["gamepadX",["gamepadY","rightBumper"]]}},
            {"type":"steeringWheel"},
            {"type":"button","action":"gamepadB","styles":{"default":{"faceImage":
              {"type":"asset","value":{"$ref":"../../context.json#/state/shieldImage"}}}}}]},
          "layers":{"WeaponLayer":{
            "right":{"outer":[[{"type":"throttle","axisUp":"rightTrigger","axisDown":"leftTrigger",
              "sticky":true},null],{"type":"blank"}]},
            "sensors":[{"type":"gyroscope","axis":{"input":"axisXY","output":"relativeMouse",
              "sensitivity":4}}]}}},
         "styles":{"colors":{"default":{"system_accentPrimary":"#1E90FF"},
           "highContrast":{"system_accentPrimary":"#FFF"}}},
         "definitions":{"moveStick":{"type":"joystick","axis":{"input":"axisXY","output":"leftJoystick"},
           "styles":{"default":{"knob":{"faceImage":{"$ref":"../../context.json#/definitions/walkIcon"}}}}}}}
        """
    }

    static var dummyLayeredContext: String {
        """
        {"definitions":{"walkIcon":{"type":"icon","value":"walk"}},
         "state":{"canSwitchWeapons":false,"shieldImage":"ShieldIdle"}}
        """
    }

    static var dummyInputConfigurations: String {
        """
        [{"supportedTabs":[{"id":"7c1e2f-touch"}],"supportedInputTypes":["Controller","CustomTouchOverlay","HandheldGyro"]},
         {"supportedTabs":[],"supportedInputTypes":["Controller","MKB"]}]
        """
    }
}
