import SwiftUI

struct GameOverView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        VStack(spacing: 10) {
            Text("お別れの時間")
                .font(.headline)
            Text("また育てることができます")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button("最初から") {
                store.reset()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct GameOverView_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView()
            .environmentObject(GameStore())
    }
}
