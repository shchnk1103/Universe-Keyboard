import SwiftUI

struct PresentedSchemeLicense: Identifiable {
    let schemaID: String
    let license: ThirdPartyLicenseDescriptor

    var id: String { schemaID }
}

/// A scheme-driven license sheet. The selected catalog item owns every piece
/// of displayed content; this view intentionally contains no scheme IDs.
struct SchemeLicenseView: View {
    @Environment(\.dismiss) private var dismiss

    let license: ThirdPartyLicenseDescriptor
    var acceptTitle = "我已阅读"
    var acceptSystemImage = "checkmark"
    let onAccept: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                LicenseDetailsSections(license: license)
            }
            .navigationTitle("\(license.projectName)许可证")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                acceptButton
            }
        }
    }

    private var acceptButton: some View {
        VStack(spacing: 0) {
            Divider()
            AppActionButton(
                title: acceptTitle,
                systemImage: acceptSystemImage,
                prominence: .primary,
                minHeight: 46
            ) {
                onAccept()
                dismiss()
            }
            .padding()
        }
        .background(.regularMaterial)
    }
}

struct OpenSourceLicensesView: View {
    var body: some View {
        List {
            Section {
                ForEach(ThirdPartyLicenseCatalog.downloadableSchemes) { license in
                    noticeLink(license)
                }
            } header: {
                Text("可选下载方案")
            } footer: {
                Text("这些方案只会在你主动操作后由主 App 下载；许可证和来源可在下载前及安装后随时查看。")
            }

            Section {
                ForEach(ThirdPartyLicenseCatalog.bundledContent) { license in
                    noticeLink(license)
                }
            } header: {
                Text("随 App 提供的内容与组件")
            } footer: {
                Text("各项目仍由原作者和贡献者拥有版权。Universe Keyboard 的使用、修改和分发须遵守对应许可证原文。")
            }
        }
        .navigationTitle("开源软件与内容")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func noticeLink(_ license: ThirdPartyLicenseDescriptor) -> some View {
        NavigationLink {
            ThirdPartyLicenseDetailView(license: license)
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(license.projectName)
                    .foregroundStyle(.primary)
                Text(license.licenseName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

private struct ThirdPartyLicenseDetailView: View {
    let license: ThirdPartyLicenseDescriptor

    var body: some View {
        Form {
            LicenseDetailsSections(license: license)
        }
        .navigationTitle(license.projectName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LicenseDetailsSections: View {
    let license: ThirdPartyLicenseDescriptor

    var body: some View {
        Section {
            LabeledContent("项目", value: license.projectName)
            LabeledContent("许可证", value: license.licenseName)
        } header: {
            Text("许可信息")
        }

        Section {
            Text(license.attribution)
            Text(license.usageNote)
            if let modificationNotice = license.modificationNotice {
                Text(modificationNotice)
            }
        } header: {
            Text("来源与使用方式")
        }

        Section {
            ForEach(license.summaryItems, id: \.self) { item in
                BulletRow(text: item, style: .dot, bulletColor: .secondary)
            }
        } header: {
            Text("摘要")
        } footer: {
            Text("摘要仅用于帮助理解，不替代许可证原文，也不构成法律意见。")
        }

        Section {
            ForEach(license.offlineDocuments) { document in
                NavigationLink {
                    ThirdPartyLicenseDocumentView(document: document)
                } label: {
                    Label(document.title, systemImage: "doc.plaintext")
                }
            }
            Link(destination: license.sourceURL) {
                Label("查看上游项目", systemImage: "arrow.up.right.square")
            }
            Link(destination: license.licenseURL) {
                Label("查看完整许可证原文", systemImage: "doc.text")
            }
        } header: {
            Text("原始资料")
        } footer: {
            Text("许可证原文可离线查看；外部链接只由主 App 在你点击时打开，键盘扩展不会访问这些页面。")
        }
    }
}

private struct ThirdPartyLicenseDocumentView: View {
    let document: ThirdPartyNoticeDocument

    var body: some View {
        ScrollView {
            Text(documentText)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var documentText: String {
        let nestedURL = Bundle.main.url(
            forResource: document.resourceName,
            withExtension: "txt",
            subdirectory: "ThirdPartyLicenses"
        )
        let resourceURL = nestedURL ?? Bundle.main.url(forResource: document.resourceName, withExtension: "txt")
        guard let resourceURL, let text = try? String(contentsOf: resourceURL, encoding: .utf8) else {
            return "许可证资源暂时无法读取。请通过上游许可证链接查看原文。"
        }
        return text
    }
}

#Preview("雾凇许可证") {
    SchemeLicenseView(license: ThirdPartyLicenseCatalog.rimeIce, onAccept: {})
}

#Preview("许可证清单") {
    NavigationStack {
        OpenSourceLicensesView()
    }
}
