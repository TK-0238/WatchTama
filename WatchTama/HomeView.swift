import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                header
                if let message = store.lastMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                }
                statusSection
                actionSection
                navigationSection
            }
            .padding(.vertical, 8)
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            PetAvatarView()
            if let state = store.state {
                Text(state.name)
                    .font(.headline)
                Text("\(stageLabel(for: state))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if state.isSleeping {
                    Text("睡眠中")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    private var statusSection: some View {
        VStack(spacing: 6) {
            StatusRowView(label: "空腹", value: store.state?.stats.hunger ?? 0)
            StatusRowView(label: "機嫌", value: store.state?.stats.mood ?? 0)
            StatusRowView(label: "清潔", value: store.state?.stats.clean ?? 0)
            StatusRowView(label: "体力", value: store.state?.stats.energy ?? 0)
            StatusRowView(label: "眠気", value: store.state?.stats.rest ?? 0)
        }
        .padding(.horizontal, 8)
    }

    private var actionSection: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(CareAction.allCases, id: \.self) { action in
                ActionButtonView(action: action)
            }
        }
        .padding(.horizontal, 6)
    }

    private var navigationSection: some View {
        HStack(spacing: 12) {
            NavigationLink("履歴") { HistoryView() }
            NavigationLink("設定") { SettingsView() }
        }
        .font(.footnote)
    }

    private func stageLabel(for state: GameState) -> String {
        switch state.stage {
        case 0: return "幼体"
        case 1: return "成体"
        default: return "最終: \(state.branch)"
        }
    }
}

struct PetAvatarView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        Text(emoji)
            .font(.system(size: 42))
            .frame(width: 64, height: 64)
            .background(Circle().fill(Color.gray.opacity(0.15)))
    }

    private var emoji: String {
        guard let state = store.state else { return "🥚" }
        if state.isGameOver {
            return "🌙"
        }
        if state.stage == 0 { return "🥚" }
        if state.stage == 1 { return "🐣" }
        if state.branch == "おだやか" { return "🐥" }
        return "🐤"
    }
}

struct StatusRowView: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.caption2)
                .frame(width: 36, alignment: .leading)
            ProgressView(value: value, total: 100)
                .tint(color)
            Text("\(Int(value))")
                .font(.caption2)
                .frame(width: 28, alignment: .trailing)
        }
    }

    private var color: Color {
        switch value {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .yellow
        default: return .green
        }
    }
}

struct ActionButtonView: View {
    @EnvironmentObject private var store: GameStore
    let action: CareAction

    var body: some View {
        let canPerform = store.canPerform(action: action)
        Button {
            store.perform(action: action)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: action.icon)
                Text(label)
                    .font(.caption2)
                if !canPerform.0, let reason = canPerform.1 {
                    Text(reason)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .tint(canPerform.0 ? .accentColor : .gray)
        .disabled(!canPerform.0)
    }

    private var label: String {
        if action == .sleep, store.state?.isSleeping == true {
            return "起こす"
        }
        return action.label
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GameStore())
    }
}
