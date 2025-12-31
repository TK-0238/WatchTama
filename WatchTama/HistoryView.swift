import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        List {
            if let history = store.state?.history, !history.isEmpty {
                ForEach(history) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.actionLabel)
                            .font(.headline)
                        Text(item.summary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(item.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("履歴がありません")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("履歴")
    }
}
