import SwiftUI

struct SchemaSelectionSection: View {
    let store: RimeSettingsStore
    let onShowLicense: () -> Void

    var body: some View {
        Section {
            VStack(spacing: 10) {
                ForEach(store.schemas) { schema in
                    if schema.schemaID == "rime_ice" && !schema.installed {
                        RimeIceDownloadCardView(
                            isLicenseAccepted: store.licenseAccepted,
                            onShowLicense: onShowLicense,
                            onDownload: { store.startDownload() }
                        )
                    } else {
                        SchemaPickerRow(
                            schema: schema,
                            isActive: schema.schemaID == store.activeSchemaID,
                            onSelect: { Task { await store.switchToSchema(schema.schemaID) } }
                        )
                    }
                }
            }
        } header: {
            Text("输入方案")
        } footer: {
            if store.activeSchemaID == "rime_ice" {
                Text("雾凇拼音词库来源于社区维护的 rime-ice 项目，通过 OpenCC 实现简繁转换。部分高级功能（日期输入、计算器等）暂不可用。")
            } else {
                Text("基于 RIME 官方 Luna Pinyin 方案。更多方案请下载安装。")
            }
        }
    }
}
