//
//  StreamMenuHandle.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct StreamMenuHandle: View {
    @Environment(\.dimensions) private var dimensions

    let isDimmed: Bool

    let onOpen: () -> Void

    var body: some View {
        let dimmedOpacity = 0.35

        Button {
            onOpen()
        } label: {
            Image(systemName: "chevron.compact.down")
                .font(.title3.weight(.semibold))
                .frame(
                    width: dimensions.streamMenuHandleWidth,
                    height: dimensions.streamMenuHandleHeight
                )
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        .opacity(isDimmed ? dimmedOpacity : 1)
        .animation(.easeOut(duration: 0.3), value: isDimmed)
        .accessibilityLabel(Text("stream.menu.open"))
    }
}

#if DEBUG
#Preview {
    VStack {
        StreamMenuHandle(isDimmed: false) {}

        StreamMenuHandle(isDimmed: true) {}
    }
    .padding()
    .background(.black)
    .environment(\.colorScheme, .dark)
}
#endif
