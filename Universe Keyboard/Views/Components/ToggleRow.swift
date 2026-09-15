//
//  ToggleRow.swift
//  Universe Keyboard
//
//  设置开关行：标题 + 说明 + 系统原生 Toggle。
//

import SwiftUI

/// Title + description + shared `AppSwitch` chrome.
///
/// All main-App switches use `.toggleStyle(.appSwitch)`, which hosts system
/// `UISwitch` and applies `AppSwitchChrome`. Do not reintroduce custom-drawn
/// `ToggleStyle` chrome — that class correlated with `SwiftUI.AsyncRenderer` /
/// libdispatch crashes on the diagnostics page.
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
            .toggleStyle(.appSwitch)
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
