//
//  HomeCard.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct HomeCard<Artwork: View, Actions: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @State private var isHovering = false
    @FocusState private var isFocused: Bool

    let heading: HomeCardHeading
    let primaryAction: HomeCardAction
    @ViewBuilder let artwork: Artwork
    @ViewBuilder let actions: Actions

    var body: some View {
        VStack(spacing: 0) {
            artworkArea

            information
        }
        .frame(width: dimensions.homeCardWidth, height: dimensions.homeCardHeight)
        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
        .cardSurface(highlighted: isFocused)
        .shadow(
            color: .black.opacity(isHovering ? 0.55 : 0.3),
            radius: isHovering ? dimensions.shadowRadiusLarge : dimensions.shadowRadiusMedium,
            y: isHovering ? dimensions.shadowOffsetLarge : dimensions.shadowOffsetMedium
        )
        .offset(y: isLifted ? -dimensions.spaceSmall : 0)
        .animation(.spring(duration: 0.35, bounce: 0.3), value: isHovering)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .contentShape(.rect(cornerRadius: dimensions.cornerRadiusXLarge))
        .onHover { isHovering = $0 }
        .onTapGesture(perform: performPrimaryActionIfEnabled)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onKeyPress(.return, action: pressReturn)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            Text("home.card.accessibilityLabel \(heading.title) \(heading.status.text)")
        )
    }
}

// MARK: - Private

private extension HomeCard {
    var artworkHoverScale: CGFloat {
        1.04
    }

    var isLifted: Bool {
        isHovering && !reduceMotion
    }

    var artworkArea: some View {
        artwork
            .frame(width: dimensions.homeCardWidth, height: dimensions.homeCardArtworkHeight)
            .clipped()
            .scaleEffect(isLifted ? artworkHoverScale : 1)
    }

    var information: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            HStack(alignment: .firstTextBaseline) {
                heading.title
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: dimensions.spaceSmall)

                statusLabel
            }

            heading.subtitle
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: dimensions.spaceSmall) {
                actions

                Spacer()

                primaryButton
            }
        }
        .padding(dimensions.spaceLarge)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    var statusLabel: some View {
        HStack(spacing: dimensions.spaceXSmall) {
            StatusDot(color: heading.status.color, pulsing: heading.status.isPulsing)

            if heading.status.isTextShown {
                heading.status.text
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(heading.status.text)
    }

    var primaryButton: some View {
        Button(action: primaryAction.onPerform) {
            Label(primaryAction.title, systemImage: primaryAction.systemImage)
                .font(.callout.weight(.semibold))
        }
        .buttonStyle(PrimaryButtonStyle(size: .compact))
        .disabled(!primaryAction.isEnabled)
        .help(Text(primaryAction.title))
    }

    func performPrimaryActionIfEnabled() {
        guard primaryAction.isEnabled else { return }

        primaryAction.onPerform()
    }

    func pressReturn() -> KeyPress.Result {
        guard primaryAction.isEnabled else { return .ignored }

        primaryAction.onPerform()

        return .handled
    }
}

// MARK: - Previews

#if DEBUG
#Preview {
    HomeCard(
        heading: .init(
            title: Text(verbatim: "Living Room"),
            subtitle: Text(verbatim: "Xbox Series X"),
            status: .init(
                text: Text(verbatim: "On"),
                color: .online,
                isPulsing: true,
                isTextShown: true
            )
        ),
        primaryAction: .init(
            title: "home.console.play",
            systemImage: "play.fill",
            isEnabled: true,
            onPerform: {}
        )
    ) {
        SkyBackground()
    } actions: {
        SettingsShortcutButton()
    }
    .padding()
    .environment(\.colorScheme, .dark)
}
#endif
