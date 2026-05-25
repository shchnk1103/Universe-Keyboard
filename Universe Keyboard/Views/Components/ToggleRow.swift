//
//  ToggleRow.swift
//  Universe Keyboard
//
//  设置开关行：标题 + 说明 + Toggle。
//

import SwiftUI

struct MonochromeToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                configuration.isOn.toggle()
            }
        } label: {
            HStack {
                configuration.label
                Spacer(minLength: 8)
                Capsule(style: .continuous)
                    .fill(configuration.isOn ? Color.primary : Color(.systemGray4))
                    .frame(width: 51, height: 31)
                    .overlay {
                        Circle()
                            .fill(configuration.isOn ? Color(.systemBackground) : .white)
                            .shadow(color: .black.opacity(0.16), radius: 1.5, y: 1)
                            .padding(3)
                            .offset(x: configuration.isOn ? 10 : -10)
                    }
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityValue(configuration.isOn ? "开启" : "关闭")
    }
}

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
            .toggleStyle(MonochromeToggleStyle())
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
