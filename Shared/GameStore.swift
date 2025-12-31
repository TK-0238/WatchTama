import Foundation
import Combine
import UserNotifications
#if canImport(WatchKit)
import WatchKit
#endif
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class GameStore: ObservableObject {
    @Published var state: GameState?
    @Published var settings: SettingsState
    @Published var lastMessage: String?

    private let stateKey = "WatchTama.GameState"
    private let settingsKey = "WatchTama.Settings"

    init() {
        settings = Self.loadSettings()
        state = Self.loadState()
    }

    func startNew(name: String) {
        let now = Date()
        state = GameState.fresh(name: name, now: now)
        lastMessage = "\(name)が生まれた！"
        save()
        scheduleBackgroundRefresh()
    }

    func refresh() {
        guard var current = state else { return }
        let messages = GameEngine.applyTimeDelta(state: &current, now: Date())
        state = current
        if let message = messages.first {
            lastMessage = message
        }
        save()
    }

    func perform(action: CareAction) {
        guard var current = state else { return }
        let now = Date()
        _ = GameEngine.applyTimeDelta(state: &current, now: now)
        let result = GameEngine.perform(action: action, state: &current, now: now)
        state = current
        lastMessage = result.message

        if result.success {
            let historyItem = CareHistory(
                id: UUID(),
                actionId: action.id,
                actionLabel: action.label,
                timestamp: now,
                summary: result.summary
            )
            current.history.insert(historyItem, at: 0)
            if current.history.count > 20 {
                current.history = Array(current.history.prefix(20))
            }
            state = current
        }

        save()
        scheduleBackgroundRefresh()
    }

    func canPerform(action: CareAction) -> (Bool, String?) {
        guard let current = state else { return (false, "未開始") }
        if current.isGameOver {
            return (false, "お別れ")
        }
        if action != .sleep, current.isSleeping {
            return (false, "睡眠中")
        }
        if let cooldownUntil = current.cooldowns[action.id], cooldownUntil > Date() {
            return (false, "クールダウン")
        }
        if action == .play, current.stats.energy < 20 {
            return (false, "体力不足")
        }
        if action == .medicine, current.stats.energy >= 70 {
            return (false, "薬は不要")
        }
        return (true, nil)
    }

    func toggleNotifications(enabled: Bool) {
        settings.notificationsEnabled = enabled
        saveSettings()
    }

    func toggleHaptics(enabled: Bool) {
        settings.hapticsEnabled = enabled
        saveSettings()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func reset() {
        state = nil
        lastMessage = nil
        save()
    }

    private func save() {
        if let state = state {
            if let data = try? JSONEncoder().encode(state) {
                AppGroup.defaults.set(data, forKey: stateKey)
            }
        } else {
            AppGroup.defaults.removeObject(forKey: stateKey)
        }
        saveSettings()
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            AppGroup.defaults.set(data, forKey: settingsKey)
        }
    }

    private static func loadState() -> GameState? {
        guard let data = AppGroup.defaults.data(forKey: "WatchTama.GameState"),
              let decoded = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return decoded
    }

    private static func loadSettings() -> SettingsState {
        guard let data = AppGroup.defaults.data(forKey: "WatchTama.Settings"),
              let decoded = try? JSONDecoder().decode(SettingsState.self, from: data) else {
            return .default
        }
        return decoded
    }

    private func scheduleBackgroundRefresh() {
        #if canImport(WatchKit)
        let preferredDate = Date().addingTimeInterval(60 * 60 * 3)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate, userInfo: nil) { _ in }
        #endif
    }
}
