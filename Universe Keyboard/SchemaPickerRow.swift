import SwiftUI

/// 方案选择行组件
struct SchemaPickerRow: View {
    let schema: SchemaMetadata
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Schema info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(schema.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        sourceBadge
                        if let version = schema.version {
                            Text(version)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }
                    }
                    Text(schema.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Status or checkmark
                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                } else if !schema.installed {
                    Text("下载")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var sourceBadge: some View {
        switch schema.source {
        case .builtin:
            Text("内置")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        case .downloaded:
            if schema.installed {
                Text("已下载")
                    .font(.caption2)
                    .foregroundStyle(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Color.green.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SchemaPickerRow(
            schema: SchemaMetadata(
                schemaID: "luna_pinyin", name: "朙月拼音",
                description: "RIME 官方基础拼音方案", source: .builtin,
                version: nil, installed: true, requiresLua: false, downloadSize: "内置"
            ),
            isActive: true,
            onSelect: {}
        )
        SchemaPickerRow(
            schema: SchemaMetadata(
                schemaID: "rime_ice", name: "雾凇拼音",
                description: "社区维护的高质量简体词库", source: .downloaded,
                version: nil, installed: false, requiresLua: true, downloadSize: "16 MB"
            ),
            isActive: false,
            onSelect: {}
        )
        SchemaPickerRow(
            schema: SchemaMetadata(
                schemaID: "rime_ice", name: "雾凇拼音",
                description: "社区维护的高质量简体词库", source: .downloaded,
                version: "2026.03.26", installed: true, requiresLua: true, downloadSize: "16 MB"
            ),
            isActive: false,
            onSelect: {}
        )
    }
    .padding()
}
