import Foundation

/// Shared 版本与下载来源 rows for every catalog scheme.
///
/// Fill rules come from catalog distribution presence, not `schemaID`.
/// Builtin / no-distribution schemes keep the same seven titles with honest
/// empty copy so a future third-party catalog entry inherits this UI.
nonisolated struct SchemeProvenancePresentation: Equatable, Sendable {
    nonisolated struct Row: Equatable, Identifiable, Sendable {
        nonisolated enum Style: Equatable, Sendable {
            case plain
            case monospacedSelectable
        }

        let title: String
        let value: String
        let style: Style

        var id: String { title }
    }

    static let navigationTitle = "版本与下载来源"
    static let distributionFooter =
        "App 仅在你开始下载后轻量选择来源，并在解压和部署前校验固定版本与内容。"
    static let builtinFooter = "此方案随 App 内置，无需下载来源。"

    static let versionTitle = "版本"
    static let sourceTitle = "下载来源"
    static let urlTitle = "下载地址"
    static let upstreamTitle = "上游版本"
    static let archiveSizeTitle = "归档大小"
    static let archiveSHATitle = "归档 SHA-256"
    static let integrityTitle = "完整性"

    let footer: String
    let rows: [Row]

    static func make(
        isDistributionBacked: Bool,
        installedVersion: String?,
        manifestVersion: String?,
        source: RimeSchemeSourceVariant?,
        hasVerifiedReceipt: Bool
    ) -> SchemeProvenancePresentation {
        if isDistributionBacked {
            return distribution(
                manifestVersion: manifestVersion,
                source: source,
                hasVerifiedReceipt: hasVerifiedReceipt
            )
        }
        return builtin(installedVersion: installedVersion)
    }

    private static func builtin(installedVersion: String?) -> SchemeProvenancePresentation {
        SchemeProvenancePresentation(
            footer: builtinFooter,
            rows: [
                Row(title: versionTitle, value: nonempty(installedVersion) ?? "随 App 内置", style: .plain),
                Row(title: sourceTitle, value: "随 App 内置", style: .plain),
                Row(title: urlTitle, value: "不适用", style: .plain),
                Row(title: upstreamTitle, value: "不适用", style: .plain),
                Row(title: archiveSizeTitle, value: "不适用", style: .plain),
                Row(title: archiveSHATitle, value: "不适用", style: .plain),
                Row(title: integrityTitle, value: "不适用", style: .plain),
            ]
        )
    }

    private static func distribution(
        manifestVersion: String?,
        source: RimeSchemeSourceVariant?,
        hasVerifiedReceipt: Bool
    ) -> SchemeProvenancePresentation {
        let archiveSize = source.map {
            ByteCountFormatter.string(fromByteCount: $0.expectedByteCount, countStyle: .file)
        }
        return SchemeProvenancePresentation(
            footer: distributionFooter,
            rows: [
                Row(title: versionTitle, value: nonempty(manifestVersion) ?? "未知", style: .plain),
                Row(
                    title: sourceTitle,
                    value: nonempty(source?.displayName) ?? "下载时自动选择",
                    style: .plain
                ),
                Row(
                    title: urlTitle,
                    value: source?.downloadURL.absoluteString ?? "下载完成后显示",
                    style: source == nil ? .plain : .monospacedSelectable
                ),
                Row(
                    title: upstreamTitle,
                    value: nonempty(source?.upstreamRevision) ?? "下载完成后显示",
                    style: source == nil ? .plain : .monospacedSelectable
                ),
                Row(title: archiveSizeTitle, value: archiveSize ?? "下载完成后显示", style: .plain),
                Row(
                    title: archiveSHATitle,
                    value: nonempty(source?.archiveSHA256) ?? "下载完成后显示",
                    style: source == nil ? .plain : .monospacedSelectable
                ),
                Row(
                    title: integrityTitle,
                    value: hasVerifiedReceipt ? "SHA-256 已验证" : "下载后验证",
                    style: .plain
                ),
            ]
        )
    }

    private static func nonempty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}
