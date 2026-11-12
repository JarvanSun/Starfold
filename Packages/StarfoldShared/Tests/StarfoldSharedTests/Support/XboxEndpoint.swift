//
//  XboxEndpoint.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum XboxEndpoint: String {
    case deviceCode = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode"
    case token = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"
    case userAuthentication = "https://user.auth.xboxlive.com/user/authenticate"
    case securityTokenAuthorization = "https://xsts.auth.xboxlive.com/xsts/authorize"
    case homeLogin = "https://xhome.gssv-play-prod.xboxlive.com/v2/login/user"
    case cloudLogin = "https://xgpuweb.gssv-play-prod.xboxlive.com/v2/login/user"
    case freeToPlayCloudLogin = "https://xgpuwebf2p.gssv-play-prod.xboxlive.com/v2/login/user"
    case profile = "https://profile.xboxlive.com/users/me/profile/settings"
    case homeConsoles = "https://uks.core.gssv-play-prodxhome.xboxlive.com/v6/servers/home"
    case cloudTitles = "https://weu.core.gssv-play-prod.xboxlive.com/v2/titles"
    case recentCloudTitles = "https://weu.core.gssv-play-prod.xboxlive.com/v2/titles/mru"
    case consoleList = "https://xccs.xboxlive.com/lists/devices"
    case consoleCommands = "https://xccs.xboxlive.com/commands"
    case presence = "https://userpresence.xboxlive.com/users/xuid(2535)"
    case titleHistory =
        "https://titlehub.xboxlive.com/users/xuid(2535)/titles/titlehistory/decoration/image"
    case catalogProducts = "https://catalog.gamepass.com/v3/products"
    case curatedList = "https://catalog.gamepass.com/sigls/v2"
    case homeRegion = "https://uks.core.gssv-play-prodxhome.xboxlive.com"
    case cloudRegion = "https://weu.core.gssv-play-prod.xboxlive.com"
}
