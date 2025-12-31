import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @State private var showResetAlert = false

    var body: some View {
        List {
            Section("通知") {
                Toggle("通知を有効", isOn: Binding(
                    get: { store.settings.notificationsEnabled },
                    set: { store.toggleNotifications(enabled: $0) }
                ))
                Button("通知を許可") {
                    store.requestNotificationPermission()
                }
            }

            Section("サウンド/触覚") {
                Toggle("触覚フィードバック", isOn: Binding(
                    get: { store.settings.hapticsEnabled },
                    set: { store.toggleHaptics(enabled: $0) }
                ))
            }

            Section("データ") {
                Button("リセット") {
                    showResetAlert = true
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("設定")
        .alert("リセットしますか？", isPresented: $showResetAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) { store.reset() }
        } message: {
            Text("名前と育成データが消えます")
        }
    }
}
