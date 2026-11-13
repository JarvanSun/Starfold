//
//  TouchLayoutEditorHost.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct TouchLayoutEditorHost: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Color.black
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
    }
}
