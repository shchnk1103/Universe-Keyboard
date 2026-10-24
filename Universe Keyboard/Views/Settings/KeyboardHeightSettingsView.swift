import SwiftUI

/// Form 中的原生导航行与固定说明，入口不读取或显示键盘保存的数值。
struct KeyboardHeightSettingsEntry: View {
    var body: some View {
        Section {
            NavigationLink {
                KeyboardHeightSettingsView()
            } label: {
                Label(KeyboardHeightSettingsCopy.title, systemImage: "arrow.up.and.down")
            }
            .accessibilityIdentifier("keyboardHeightEntry")
        } footer: {
            Text(KeyboardHeightSettingsCopy.fullAccessExplanation)
        }
    }
}

struct KeyboardHeightSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = KeyboardHeightAdjustmentPageSession()

    var body: some View {
        Form {
            Section {
                Text(KeyboardHeightSettingsCopy.instructions)
                Text(KeyboardHeightSettingsCopy.keyboardHint)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                AppActionButton(title: "重新打开调节键盘", systemImage: "keyboard", prominence: .secondary) {
                    session.reopen()
                }
                .accessibilityIdentifier("reopenKeyboardHeightAdjustment")
            } footer: {
                Text(KeyboardHeightSettingsCopy.fullAccessExplanation)
            }
        }
        .navigationTitle(KeyboardHeightSettingsCopy.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("关闭调节") {
                    session.end()
                    dismiss()
                }
                .accessibilityIdentifier("closeKeyboardHeightAdjustment")
            }
        }
        .background(alignment: .topLeading) {
            KeyboardHeightInputHost(session: session)
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onAppear { session.beginIfNeeded() }
        .onDisappear { session.end() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { session.end() }
        }
        .accessibilityAction(.escape) {
            session.end()
            dismiss()
        }
    }
}
