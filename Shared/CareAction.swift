import Foundation

enum CareAction: String, CaseIterable, Codable {
    case feed
    case play
    case clean
    case sleep
    case pet
    case medicine

    var id: String { rawValue }

    var label: String {
        switch self {
        case .feed: return "ごはん"
        case .play: return "遊ぶ"
        case .clean: return "掃除"
        case .sleep: return "寝かせる"
        case .pet: return "なでる"
        case .medicine: return "薬"
        }
    }

    var icon: String {
        switch self {
        case .feed: return "fork.knife"
        case .play: return "gamecontroller"
        case .clean: return "sparkles"
        case .sleep: return "bed.double"
        case .pet: return "hand.raised"
        case .medicine: return "cross.case"
        }
    }

    var cooldownSeconds: TimeInterval {
        switch self {
        case .feed: return 5 * 60
        case .play: return 6 * 60
        case .clean: return 4 * 60
        case .sleep: return 0
        case .pet: return 60
        case .medicine: return 10 * 60
        }
    }
}

struct CareResult {
    let success: Bool
    let message: String
    let summary: String
}
