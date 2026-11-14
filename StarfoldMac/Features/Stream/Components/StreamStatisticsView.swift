//
//  StreamStatisticsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct StreamStatisticsView: View {
    @Environment(\.dimensions) private var dimensions

    let readout: StatisticsReadout

    var body: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: dimensions.spaceMedium,
            verticalSpacing: dimensions.spaceXXSmall
        ) {
            if let latency = readout.latency {
                latencyHeadline(latency)
            }

            ForEach(readout.rows) { row($0) }
        }
        .font(.caption.monospacedDigit())
        .fixedSize()
        .padding(dimensions.spaceMedium)
        .glassEffect(in: .rect(cornerRadius: dimensions.cornerRadiusMedium))
        .environment(\.colorScheme, .dark)
    }

    @ViewBuilder
    private func latencyHeadline(_ latency: StatisticsLatency) -> some View {
        GridRow {
            Text("stream.statistics.latency.title")
                .foregroundStyle(.secondary)

            HStack(spacing: dimensions.spaceXSmall) {
                StatusDot(color: latency.level.color)

                Text(verbatim: latency.value)
            }
            .font(.callout.weight(.semibold).monospacedDigit())
        }
        .help(Text("stream.statistics.latency.tooltip"))

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
#Preview {
    StreamStatisticsView(readout: PreviewObjectPool.statisticsReadout)
        .padding()
        .background(.black)
}
#endif
