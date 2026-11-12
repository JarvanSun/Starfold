//
//  AppInfo.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation

public struct AppInfo {
    public var displayName: String {
        string(for: .displayName) ?? string(for: .bundleName) ?? ""
    }

    public var version: String {
        string(for: .shortVersion) ?? ""
    }

    public init() {}
}

private enum InfoKey: String {
    case displayName = "CFBundleDisplayName"
    case bundleName = "CFBundleName"
    case shortVersion = "CFBundleShortVersionString"
}

private extension AppInfo {
    func string(for key: InfoKey) -> String? {
        Bundle.main.infoDictionary?[key.rawValue] as? String
    }
}
