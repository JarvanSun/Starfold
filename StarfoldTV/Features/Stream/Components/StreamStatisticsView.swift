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
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            switch readout.latency {
            case let latency?: latencyLine(latency)
            case nil: EmptyView()
            }

            ForEach(readout.rows) { row in
                Text(verbatim: row.value)
            }
        }
        .font(.callout.monospacedDigit())
        .padding(dimensions.spaceXLarge)
        .background(.regularMaterial, in: .rect(cornerRadius: dimensions.cornerRadiusLarge))
    }
}

private extension StreamStatisticsView {
    func latencyLine(_ latency: StatisticsLatency) -> some View {
        HStack {
            Text("stream.statistics.latency")
                .foregroundStyle(.secondary)

            Text(verbatim: latency.value)
        }
    }
}

#if DEBUG
#Preview {
    StreamStatisticsView(readout: PreviewObjectPool.statisticsReadout)
}
#endif
