import WidgetKit
import SwiftUI

struct TamaEntry: TimelineEntry {
    let date: Date
    let state: GameState?
}

struct TamaProvider: TimelineProvider {
    func placeholder(in context: Context) -> TamaEntry {
        TamaEntry(date: Date(), state: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TamaEntry) -> Void) {
        completion(TamaEntry(date: Date(), state: WidgetDataSource.loadState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TamaEntry>) -> Void) {
        let now = Date()
        let entry = TamaEntry(date: now, state: WidgetDataSource.loadState())
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: now) ?? now.addingTimeInterval(7200)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct WatchTamaWidget: Widget {
    let kind: String = "WatchTamaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TamaProvider()) { entry in
            WatchTamaWidgetView(entry: entry)
        }
        .configurationDisplayName("WatchTama")
        .description("空腹と機嫌をサッと確認")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct WatchTamaWidgetView: View {
    let entry: TamaEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Gauge(value: hungerValue, in: 0...100) {
                    Text("空腹")
                }
                .gaugeStyle(.accessoryCircular)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.state?.name ?? "WatchTama")
                    .font(.caption)
                Text("空腹 \(Int(hungerValue))")
                Text("機嫌 \(Int(moodValue))")
            }
        case .accessoryInline:
            Text("空腹 \(Int(hungerValue))%")
        default:
            Text("WatchTama")
        }
    }

    private var hungerValue: Double {
        entry.state?.stats.hunger ?? 0
    }

    private var moodValue: Double {
        entry.state?.stats.mood ?? 0
    }
}

struct WatchTamaWidget_Previews: PreviewProvider {
    static var previews: some View {
        WatchTamaWidgetView(entry: TamaEntry(date: Date(), state: nil))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
