//
//  TouchStickPlaceholder.swift
//  StarfoldiOS
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchStickPlaceholder: View {
    @Environment(\.dimensions) private var dimensions

    let visibility: TouchStickVisibility
    let diameter: CGFloat

    var body: some View {
        if let symbol = visibility.placeholderSymbol {
            Circle()
                .strokeBorder(
                    .white,
                    style: StrokeStyle(
                        lineWidth: dimensions.highlightLineWidth,
                        dash: [dimensions.touchPlaceholderDash]
                    )
                )
                .overlay {
                    Image(systemName: symbol)
                        .font(.title)
                }
                .foregroundStyle(.white)
                .opacity(emphasis)
                .frame(width: diameter, height: diameter)
                .accessibilityHidden(true)
        }
    }

    private var emphasis: Double {
        let onTouchOpacity = 0.6
        let offOpacity = 0.35

        return switch visibility {
        case .always, .onTouch: onTouchOpacity
        case .off: offOpacity
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        TouchStickPlaceholder(visibility: .onTouch, diameter: 124)
        TouchStickPlaceholder(visibility: .off, diameter: 124)
    }
    .padding()
    .background(.black)
}
#endif
