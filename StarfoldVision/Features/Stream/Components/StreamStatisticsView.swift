//
//  StreamStatisticsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI

struct StreamStatisticsView: View {
    @Environment(\.dimensions) private var dimensions

    let readout: StatisticsReadout

    var body: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: dimensions.spaceLarge,
            verticalSpacing: dimensions.spaceXSmall
        ) {
            switch readout.latency {
            case let latency?: latencyHeadline(latency)
            case nil: EmptyView()
            }

            ForEach(readout.rows) { row($0) }
        }
        .font(.callout.monospacedDigit())
        .fixedSize()
        .padding(dimensions.spaceLarge)
        .glassBackgroundEffect(in: .rect(cornerRadius: dimensions.cornerRadiusXLarge))
    }

    @ViewBuilder
    private func latencyHeadline(_ latency: StatisticsLatency) -> some View {
        GridRow {
            Text("stream.statistics.latency")
                .foregroundStyle(.secondary)

            HStack(spacing: dimensions.spaceSmall) {
                StatusDot(color: latency.level.color)

                Text(verbatim: latency.value)
            }
            .font(.headline.monospacedDigit())
        }

        Divider()
            .gridCellColumns(2)
            .padding(.vertical, dimensions.spaceXSmall)
    }

    private func row(_ row: StatisticsRow) -> some View {
        GridRow {
            label(of: row.kind)

            Text(verbatim: row.value)
        }
    }

    @ViewBuilder
    private func label(of kind: StatisticsRowKind) -> some View {
        switch kind.label {
        case let label?: Text(label).foregroundStyle(.secondary)
        case nil: Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        }
    }
}

#if DEBUG
#Preview("Statistics", windowStyle: .plain) {
    StreamStatisticsView(readout: PreviewObjectPool.statisticsReadout)
}
#endif
