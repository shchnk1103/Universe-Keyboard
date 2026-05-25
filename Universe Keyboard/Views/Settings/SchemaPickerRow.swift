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
                            CapsuleBadge(text: version, color: .secondary, style: .tinted)
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
                        .foregroundStyle(.primary)
                } else if !schema.installed {
                    CapsuleBadge(text: "下载", color: .primary, style: .filled)
                }
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? Color.primary.opacity(0.35) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var sourceBadge: some View {
        switch schema.source {
        case .builtin:
            CapsuleBadge(text: "内置", color: Color(.systemGray5), style: .tinted)
        case .downloaded:
            if schema.installed {
                CapsuleBadge(text: "已下载", color: .green, style: .tinted)
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
