import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: GameStore
    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("育成を始めよう")
                .font(.headline)
            TextField("名前", text: $name)
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 120)
            Button("育成を開始") {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    store.startNew(name: String(trimmed.prefix(8)))
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Text("名前は後から変更できません")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(GameStore())
    }
}
