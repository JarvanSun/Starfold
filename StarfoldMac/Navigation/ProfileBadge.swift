//
//  ProfileBadge.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct ProfileBadge: View {
    @Environment(\.dimensions) private var dimensions

    let gamertag: String
    let profile: XboxProfile?

    var body: some View {
        HStack(spacing: dimensions.spaceSmall) {
            picture

            VStack(alignment: .leading, spacing: 0) {
                name

                switch profile?.gamerscore {
                case let gamerscore?: gamerscoreLabel(gamerscore)
                case nil: EmptyView()
                }
            }
        }
        .padding(.leading, dimensions.spaceXSmall)
        .padding(.trailing, dimensions.spaceMedium)
        .padding(.vertical, dimensions.spaceXSmall)
        .contentShape(.rect)
    }

    private var picture: some View {
        AsyncImage(url: profile?.pictureURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.secondary)
        }
        .frame(width: dimensions.profilePictureSize, height: dimensions.profilePictureSize)
        .clipShape(.circle)
        .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: dimensions.hairline))
    }

    private var name: some View {
        Text(gamertag)
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
    }

    private func gamerscoreLabel(_ gamerscore: Int) -> some View {
        Label {
            Text(gamerscore, format: .number)
        } icon: {
            gamerscoreSymbol
        }
        .labelStyle(GamerscoreLabelStyle(spacing: dimensions.spaceXSmall))
        .font(.caption.monospacedDigit())
        .foregroundStyle(.secondary)
    }

    private var gamerscoreSymbol: some View {
        Text("account.badge.gamerscoreSymbol")
            .font(.caption2.bold())
            .frame(width: dimensions.gamerscoreSymbolSize, height: dimensions.gamerscoreSymbolSize)
            .background(.secondary.opacity(0.3), in: .circle)
    }
}

private struct GamerscoreLabelStyle: LabelStyle {
    let spacing: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon

            configuration.title
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        ProfileBadge(
            gamertag: PreviewObjectPool.profile.gamertag,
            profile: PreviewObjectPool.profile
        )

        ProfileBadge(gamertag: PreviewObjectPool.profile.gamertag, profile: nil)
    }
    .padding()
}
#endif
