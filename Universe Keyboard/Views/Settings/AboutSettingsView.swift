import SwiftUI

/// Main-App identity and contact hub (`PD-APP-ABOUT-001`).
struct AboutSettingsView: View {
    @Environment(\.openURL) private var openURL

    private var marketingVersion: String { AppAboutContact.marketingVersion() }
    private var buildNumber: String { AppAboutContact.buildNumber() }

    var body: some View {
        List {
            Section {
                LabeledContent("版本", value: marketingVersion)
                LabeledContent("Build", value: buildNumber)
            } header: {
                Text("Universe Keyboard")
            } footer: {
                Text("长按版本或 Build 可复制，方便在反馈里说明当前安装。")
            }

            Section {
                Button {
                    if let url = AppAboutContact.feedbackMailtoURL(
                        version: marketingVersion,
                        build: buildNumber
                    ) {
                        openURL(url)
                    }
                } label: {
                    Label("邮件", systemImage: "envelope")
                }
                .contentShape(Rectangle())

                Button {
                    openURL(AppAboutContact.xiaohongshuURL)
                } label: {
                    Label("小红书", systemImage: "link")
                }
                .contentShape(Rectangle())
            } header: {
                Text("联系我们")
            } footer: {
                Text("请不要在邮件或社区里发送输入内容或完整诊断日志。")
            }

            Section {
                NavigationLink {
                    PrivacyDataView()
                } label: {
                    Label("隐私与数据", systemImage: "hand.raised")
                }

                NavigationLink {
                    OpenSourceLicensesView()
                } label: {
                    Label("开源软件与内容", systemImage: "doc.text")
                }
            }
        }
        .textSelection(.enabled)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
