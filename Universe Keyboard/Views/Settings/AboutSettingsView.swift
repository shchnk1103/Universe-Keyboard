import SwiftUI

/// PB-015 PR-4（M6）：诊断入口收进关于页的文案锚点（测试与文档共用）。
enum AboutSettingsCopy {
    static let diagnosticsSectionHeader = "诊断"
    static let diagnosticsEntryTitle = "诊断"
}

/// Main-App identity and contact hub (`PD-APP-ABOUT-001`).
struct AboutSettingsView: View {
    @Bindable var notificationSettings: AppNotificationSettingsModel
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

            // PB-015 PR-4（M6）：诊断入口从根设置页独立组迁入关于页尾部。
            Section {
                NavigationLink {
                    DiagnosticsSettingsView(notificationSettings: notificationSettings)
                } label: {
                    Label(
                        AboutSettingsCopy.diagnosticsEntryTitle,
                        systemImage: "waveform.path.ecg.text"
                    )
                }
            } header: {
                Text(AboutSettingsCopy.diagnosticsSectionHeader)
            } footer: {
                Text("本机记录、分类与高级排查。排查问题时再打开即可。")
            }

            if let filingNumber = AppAboutContact.icpFilingDisplayText(AppAboutContact.icpFilingNumber) {
                Section {
                    Button {
                        openURL(AppAboutContact.icpFilingLookupURL)
                    } label: {
                        LabeledContent("ICP 备案号", value: filingNumber)
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .textSelection(.enabled)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}
