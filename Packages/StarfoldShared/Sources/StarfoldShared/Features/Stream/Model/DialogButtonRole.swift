//
//  DialogButtonRole.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum DialogButtonRole: Equatable {
    case primary
    case cancel
    case plain

    init(buttonAt index: Int, defaultIndex: Int, cancelIndex: Int?) {
        self =
            switch (index == defaultIndex, index == cancelIndex) {
            case (true, _): .primary
            case (false, true): .cancel
            case (false, false): .plain
            }
    }
}
