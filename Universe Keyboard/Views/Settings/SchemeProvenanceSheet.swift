import SwiftUI

struct SchemeProvenanceSheet: View {
    let presentation: SchemeProvenancePresentation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(presentation.rows) { row in
                        provenanceRow(row)
                    }
                } footer: {
                    Text(presentation.footer)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(SchemeProvenancePresentation.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成", action: dismiss.callAsFunction)
                }
            }
        }
    }

    @ViewBuilder
    private func provenanceRow(_ row: SchemeProvenancePresentation.Row) -> some View {
        switch row.style {
        case .plain:
            KeyValueRow(title: row.title, value: row.value)
        case .monospacedSelectable:
            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(row.value)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(row.title)，\(row.value)")
        }
    }
}
