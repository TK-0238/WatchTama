import Foundation

enum AppGroup {
    static let id = "group.com.watchtama.shared"
    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }
}
