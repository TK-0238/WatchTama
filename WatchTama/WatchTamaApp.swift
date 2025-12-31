import SwiftUI

@main
struct WatchTamaApp: App {
    @StateObject private var store = GameStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                store.refresh()
            }
        }
    }
}
