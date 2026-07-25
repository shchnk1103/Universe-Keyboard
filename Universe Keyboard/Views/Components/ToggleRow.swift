//
//  ToggleRow.swift
//  Universe Keyboard
//
//  设置开关行：标题 + 说明 + 系统原生 Toggle。
//

import SwiftUI

/// Title + description + system switch.
///
/// Product preference: use native `.toggleStyle(.switch)` everywhere (including Form).
/// Custom drawn switches were retired after Form + custom styles correlated with
/// `SwiftUI.AsyncRenderer` / libdispatch crashes on the diagnostics page.
struct ToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.body)
            }
            .toggleStyle(.switch)
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
