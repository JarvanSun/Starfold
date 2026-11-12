//
//  URLExtensions.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension URL {
    init?(upgradingXboxImageToHTTPS text: String) {
        guard var components = URLComponents(string: text) else {
            return nil
        }

        if components.scheme == "http" {
            components.scheme = "https"

            if components.host == "images-eds.xboxlive.com" {
                components.host = "images-eds-ssl.xboxlive.com"
            }
        }

        guard let url = components.url else {
            return nil
        }

        self = url
    }
}
