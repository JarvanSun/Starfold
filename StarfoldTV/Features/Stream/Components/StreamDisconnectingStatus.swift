//
//  StreamDisconnectingStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamDisconnectingStatus: View {
    @Environment(\.dimensions) private var dimensions

    var body: some View {
        Text("stream.status.disconnecting")
            .font(.title)
            .padding(dimensions.spaceXXXLarge)
            .background(.regularMaterial)
    }
}

#if DEBUG
#Preview {
    StreamDisconnectingStatus()
}
#endif
