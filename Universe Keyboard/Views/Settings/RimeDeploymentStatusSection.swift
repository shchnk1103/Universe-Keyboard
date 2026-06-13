import SwiftUI

struct RimeDeploymentStatusSection: View {
    let store: RimeSettingsStore
    @Binding var logExpanded: Bool

    var body: some View {
        Section {
            RimeDeploymentContent(
                state: store.deploymentState,
                statusHint: store.deploymentStatusHint,
                deployLog: store.deploymentLog,
                logExpanded: $logExpanded,
                onTriggerDeploy: { Task { await store.triggerDeployment() } },
                onCancel: { store.cancelDeployment() },
                onReset: { store.resetDeploymentStatus() }
            )
        } header: {
            Text("部署")
        } footer: {
            Text("修改设置后请在此完成部署。部署进度和结果会显示在底部全局提示中；成功后切换到键盘即可直接使用。")
        }
    }
}
