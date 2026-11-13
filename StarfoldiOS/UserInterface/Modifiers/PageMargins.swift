//
//  PageMargins.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

extension View {
    func pageMargins() -> some View {
        modifier(PageMargins(placement: .padding))
    }

    func pageScrollMargins() -> some View {
        modifier(PageMargins(placement: .scrollContent))
    }
}

private struct PageMargins: ViewModifier {
    enum Placement {
        case padding
        case scrollContent
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dimensions) private var dimensions

    let placement: Placement

    func body(content: Content) -> some View {
        switch placement {
        case .padding: content.padding(.horizontal, margin)
        case .scrollContent: content.contentMargins(.horizontal, margin, for: .scrollContent)
        }
    }

    private var margin: CGFloat {
        switch horizontalSizeClass {
        case .compact: dimensions.spaceLarge
        default: dimensions.spaceXXLarge
        }
    }
}
