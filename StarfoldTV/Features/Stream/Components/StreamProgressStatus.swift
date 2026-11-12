//
//  StreamProgressStatus.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamProgressStatus: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource

    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: dimensions.spaceXXLarge) {
            Text(title)

            ProgressView()

            Button("common.cancel") { onCancel() }
        }
    }
}

#if DEBUG
#Preview {
    StreamProgressStatus(title: StreamStatus.connecting.title) {}
}
#endif
