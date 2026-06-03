import SwiftUI

struct SchemaDownloadSection: View {
    let store: RimeSettingsStore
    let onShowLicense: () -> Void
    let onUninstall: () -> Void

    var body: some View {
        if !store.isRimeIceInstalled {
            Section {
                RimeIceInfoContent()
            } header: {
                Text("可用方案")
            }
        }

        if store.isShowingDownloadProgress {
            Section {
                RimeDownloadProgressContent(
                    statusLabel: store.downloadStatusLabel,
                    state: store.downloadState,
                    onCancel: { store.cancelDownload() }
                )
            } header: {
                Text("下载进度")
            }
        }

        if case .failed(let message) = store.downloadState {
            Section {
                RimeDownloadErrorContent(message: message, onRetry: { store.startDownload() })
            } header: {
                Text("下载失败")
            }
        }

        if store.isRimeIceInstalled {
            Section {
                RimeIceManageContent(
                    version: store.rimeIceVersion,
                    updateStatusMessage: store.updateStatusMessage,
                    onCheckForUpdate: { Task { await store.checkForUpdateAndDownload() } },
                    onRedownload: { store.forceRedownload() },
                    onUninstall: onUninstall,
                    onShowLicense: onShowLicense
                )
            } header: {
                Text("雾凇拼音管理")
            }
        }
    }
}
