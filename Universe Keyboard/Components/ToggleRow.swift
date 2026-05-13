//
//  ToggleRow.swift
//  Universe Keyboard
//
//  设置开关行：标题 + 说明 + Toggle。
//

import SwiftUI

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
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
