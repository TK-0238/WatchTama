import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        Group {
            if let state = store.state {
                if state.isGameOver {
                    GameOverView()
                } else {
                    NavigationStack {
                        HomeView()
                    }
                }
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            store.refresh()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameStore())
    }
}
