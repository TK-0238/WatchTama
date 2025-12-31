import Foundation

enum GameEngine {
    static let stageThresholds: [Int: Double] = [
        1: 24.0,  // hours
        2: 72.0
    ]

    static func applyTimeDelta(state: inout GameState, now: Date) -> [String] {
        guard now > state.lastUpdatedAt else { return [] }
        let delta = now.timeIntervalSince(state.lastUpdatedAt)
        if delta < 30 { return [] }

        let hours = delta / 3600.0
        var messages: [String] = []

        if state.isSleeping {
            state.stats.hunger -= hours * 4.0
            state.stats.clean -= hours * 2.5
            state.stats.mood -= hours * 1.5
            state.stats.energy += hours * 6.0
            state.stats.rest += hours * 12.0
        } else {
            state.stats.hunger -= hours * 8.0
            state.stats.mood -= hours * 5.0
            state.stats.clean -= hours * 6.0
            state.stats.energy -= hours * 4.0
            state.stats.rest -= hours * 7.0
        }

        state.stats.clamp()
        state.lastUpdatedAt = now

        if state.stats.hunger <= 0 || state.stats.energy <= 0 || state.stats.clean <= 0 {
            state.isGameOver = true
            messages.append("体調が限界に…しばらく休ませてあげてください")
        }

        if let evolutionMessage = checkEvolution(state: &state, now: now) {
            messages.append(evolutionMessage)
        }

        return messages
    }

    static func checkEvolution(state: inout GameState, now: Date) -> String? {
        let ageHours = now.timeIntervalSince(state.bornAt) / 3600.0

        if state.stage < 1, ageHours >= stageThresholds[1, default: 24.0] {
            state.stage = 1
            state.branch = "まめ"
            return "少し大きくなった！"
        }

        if state.stage < 2, ageHours >= stageThresholds[2, default: 72.0] {
            state.stage = 2
            let average = state.stats.average
            if average >= 70 {
                state.branch = "おだやか"
            } else {
                state.branch = "のんびり"
            }
            return "最終形態に進化！"
        }

        return nil
    }

    static func perform(action: CareAction, state: inout GameState, now: Date) -> CareResult {
        if state.isGameOver {
            return CareResult(success: false, message: "もうこれ以上は無理みたい…", summary: "実行不可")
        }

        if action != .sleep, state.isSleeping {
            return CareResult(success: false, message: "すやすや眠っています", summary: "睡眠中")
        }

        if let cooldownUntil = state.cooldowns[action.id], cooldownUntil > now {
            let remain = Int(cooldownUntil.timeIntervalSince(now) / 60) + 1
            return CareResult(success: false, message: "あと約\(remain)分待ってね", summary: "クールダウン")
        }

        var summaryParts: [String] = []

        switch action {
        case .feed:
            state.stats.hunger += 35
            state.stats.energy += 5
            summaryParts.append("空腹+35")
        case .play:
            if state.stats.energy < 20 {
                return CareResult(success: false, message: "元気が足りないみたい", summary: "体力不足")
            }
            state.stats.mood += 30
            state.stats.hunger -= 8
            state.stats.energy -= 10
            summaryParts.append("機嫌+30")
        case .clean:
            state.stats.clean += 35
            state.stats.mood += 2
            summaryParts.append("清潔+35")
        case .sleep:
            if state.isSleeping {
                state.isSleeping = false
                summaryParts.append("起床")
                return CareResult(success: true, message: "おはよう！", summary: "起床")
            } else {
                state.isSleeping = true
                summaryParts.append("睡眠開始")
                return CareResult(success: true, message: "すやすや…", summary: "睡眠開始")
            }
        case .pet:
            state.stats.mood += 15
            summaryParts.append("機嫌+15")
        case .medicine:
            if state.stats.energy >= 70 {
                return CareResult(success: false, message: "今は薬は要らないよ", summary: "不要")
            }
            state.stats.energy += 30
            state.stats.mood -= 5
            summaryParts.append("体力+30")
        }

        state.stats.clamp()
        state.lastCareAt = now
        state.lastUpdatedAt = now

        if action.cooldownSeconds > 0 {
            state.cooldowns[action.id] = now.addingTimeInterval(action.cooldownSeconds)
        }

        state.careCounts[action.id, default: 0] += 1

        let summary = summaryParts.joined(separator: ", ")
        return CareResult(success: true, message: "\(action.label)したよ！", summary: summary)
    }
}
