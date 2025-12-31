import Foundation

enum WidgetDataSource {
    static func loadState() -> GameState? {
        guard let data = AppGroup.defaults.data(forKey: "WatchTama.GameState"),
              let decoded = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return decoded
    }
}
