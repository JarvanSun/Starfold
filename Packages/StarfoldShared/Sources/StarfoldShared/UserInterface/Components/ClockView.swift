//
//  ClockView.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct ClockView: View {
    public init() {}

    public var body: some View {
        let textOpacity = 0.9

        TimelineView(.everyMinute) { context in
            Text(context.date, format: .dateTime.hour().minute())
                .font(.system(.headline, design: .monospaced).weight(.semibold))
                .foregroundStyle(.white.opacity(textOpacity))
                .contentTransition(.numericText())
                .animation(.smooth, value: context.date)
        }
        .accessibilityLabel(Text("theme.clock.accessibilityLabel", bundle: .module))
    }
}

#if DEBUG
#Preview {
    ClockView()
        .padding()
        .background(.black)
}
#endif
