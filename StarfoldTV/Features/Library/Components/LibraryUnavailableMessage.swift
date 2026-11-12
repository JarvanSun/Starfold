//
//  LibraryUnavailableMessage.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct LibraryUnavailableMessage: View {
    let onRefresh: () -> Void

    var body: some View {
        MessageView(
            title: "library.unavailable.title",
            message: Text("library.unavailable.message"),
            actionLabel: "library.unavailable.refresh",
            onAction: onRefresh
        )
    }
}

#if DEBUG
#Preview {
    LibraryUnavailableMessage {}
}
#endif
