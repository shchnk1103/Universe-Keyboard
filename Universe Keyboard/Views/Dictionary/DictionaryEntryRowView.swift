import SwiftUI

struct DictionaryEntryRowView: View {
    let entry: LocalDictionaryEntry

    var body: some View {
        HStack {
            Text(entry.text)
                .font(.body)
            Spacer(minLength: 12)
            Text(entry.code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            if let weight = entry.weight {
                Text(weight)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
