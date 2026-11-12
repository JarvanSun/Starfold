//
//  PreviewError.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct PreviewError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}
