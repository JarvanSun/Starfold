//
//  ViewExtensions.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension View {
    public func overlay<Value, Content: View>(
        if value: Value?,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping (Value) -> Content
    ) -> some View {
        overlay(alignment: alignment) {
            if let value {
                content(value)
            }
        }
    }

    public func palette(_ palette: Palette) -> some View {
        environment(\.palette, palette)
    }
}
