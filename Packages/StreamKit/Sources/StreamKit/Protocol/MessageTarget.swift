//
//  MessageTarget.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum MessageTarget: String {
    case systemUIConfiguration = "/streaming/systemUi/configuration"
    case clientAppInstallIDChanged = "/streaming/properties/clientappinstallidchanged"
    case orientationChanged = "/streaming/characteristics/orientationchanged"
    case touchInputEnabledChanged = "/streaming/characteristics/touchinputenabledchanged"
    case clientDeviceCapabilities = "/streaming/characteristics/clientdevicecapabilities"
    case dimensionsChanged = "/streaming/characteristics/dimensionschanged"
    case showMessageDialog = "/streaming/systemUi/messages/ShowMessageDialog"
    case showVirtualKeyboard = "/streaming/systemUi/messages/ShowVirtualKeyboard"
    case serverInitiatedDisconnect =
        "/streaming/sessionLifetimeManagement/serverInitiatedDisconnect"
    case titleInfo = "/streaming/properties/titleinfo"
}
