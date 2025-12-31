import Foundation

struct PetStats: Codable {
    var hunger: Double
    var mood: Double
    var clean: Double
    var energy: Double
    var rest: Double

    static let maxValue: Double = 100
    static let minValue: Double = 0

    mutating func clamp() {
        hunger = min(max(hunger, Self.minValue), Self.maxValue)
        mood = min(max(mood, Self.minValue), Self.maxValue)
        clean = min(max(clean, Self.minValue), Self.maxValue)
        energy = min(max(energy, Self.minValue), Self.maxValue)
        rest = min(max(rest, Self.minValue), Self.maxValue)
    }

    var average: Double {
        (hunger + mood + clean + energy + rest) / 5.0
    }
}

struct CareHistory: Codable, Identifiable {
    let id: UUID
    let actionId: String
    let actionLabel: String
    let timestamp: Date
    let summary: String
}

struct SettingsState: Codable {
    var notificationsEnabled: Bool
    var hapticsEnabled: Bool

    static let `default` = SettingsState(notificationsEnabled: true, hapticsEnabled: true)
}

struct GameState: Codable {
    var name: String
    var bornAt: Date
    var lastUpdatedAt: Date
    var lastCareAt: Date
    var stats: PetStats
    var stage: Int
    var branch: String
    var isSleeping: Bool
    var isGameOver: Bool
    var cooldowns: [String: Date]
    var history: [CareHistory]
    var careCounts: [String: Int]

    static func fresh(name: String, now: Date) -> GameState {
        GameState(
            name: name,
            bornAt: now,
            lastUpdatedAt: now,
            lastCareAt: now,
            stats: PetStats(hunger: 80, mood: 75, clean: 85, energy: 80, rest: 70),
            stage: 0,
            branch: "たまご",
            isSleeping: false,
            isGameOver: false,
            cooldowns: [:],
            history: [],
            careCounts: [:]
        )
    }
}
