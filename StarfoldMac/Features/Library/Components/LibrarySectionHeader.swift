//
//  LibrarySectionHeader.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct LibrarySectionHeader: View {
    @Environment(\.dimensions) private var dimensions

    let title: LocalizedStringResource
    let count: Int?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: dimensions.spaceSmall) {
            Text(title)
                .font(.title2.bold())

            switch count {
            case let count?: countLabel(count)
            case nil: EmptyView()
            }
        }
        .padding(.horizontal, dimensions.spaceXXLarge)
    }

    private func countLabel(_ count: Int) -> some View {
        Text(count, format: .number)
            .font(.callout.monospacedDigit())
            .foregroundStyle(.secondary)
    }
}
