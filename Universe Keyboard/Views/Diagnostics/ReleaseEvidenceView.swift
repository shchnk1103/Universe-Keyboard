import SwiftUI

/// Main App 内记录发布证据的轻量页面。
///
/// 页面只保存有限字段与人工标记，不读取日志正文，也不执行上传、分组或审核提交。
struct ReleaseEvidenceView: View {
    @State private var model = ReleaseEvidenceSessionModel.shared

    var body: some View {
        Form {
            setupSection
            if let selectedRun = model.selectedRun {
                currentRunSection(selectedRun)
            }
            historySection
            boundarySection
        }
        .navigationTitle("发布证据")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .task {
            model.load()
        }
    }

    private var setupSection: some View {
        Section {
            Picker("发布阶段", selection: $model.selectedLane) {
                ForEach(ReleaseEvidenceLane.allCases) { lane in
                    Text(lane.title).tag(lane)
                }
            }

            Text(model.selectedLane.detail)
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("验证档位", selection: $model.selectedProfile) {
                ForEach(ReleaseValidationProfile.allCases) { profile in
                    Text(profile.title).tag(profile)
                }
            }

            Text(model.selectedProfile.detail)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("候选标识（如 Build-56）", text: $model.candidateID)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: model.candidateID) { _, _ in
                    model.candidateIDError = nil
                }

            if let candidateIDError = model.candidateIDError {
                Text(candidateIDError)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            AppActionButton(
                title: "开始记录会话",
                systemImage: "plus.circle",
                prominence: .primary,
                action: model.startSession
            )
            .disabled(model.isSaving)
        } header: {
            Text("新建证据会话")
        } footer: {
            Text("候选标识只用于本机记录和导出，不包含用户输入、候选文字或日志正文。")
        }
    }

    private func currentRunSection(_ run: ReleaseEvidenceRun) -> some View {
        Section {
            KeyValueRow(title: "候选", value: run.candidateID)
            KeyValueRow(title: "版本 / 构建", value: "\(run.appVersion) / \(run.appBuild)")
            KeyValueRow(title: "设备 / 系统", value: "\(run.deviceModel) / \(run.osVersion)")
            KeyValueRow(title: "行为契约", value: run.behaviorContract)

            HStack {
                Text("当前结论")
                Spacer()
                Label(run.outcome.title, systemImage: outcomeSymbol(run.outcome))
                    .foregroundStyle(outcomeColor(run.outcome))
            }

            if let promotionMode = run.promotionMode {
                Text(promotionDescription(promotionMode))
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ForEach(run.steps) { step in
                evidenceStepRow(step, runID: run.id)
            }

            if run.lane == .dailyBeta, run.isCompletePass {
                AppActionButton(
                    title: "复制为外部候选",
                    systemImage: "arrow.up.right.square",
                    prominence: .primary,
                    action: model.promoteSelectedRun
                )
                .disabled(model.isSaving)
            }

            if !model.exportText.isEmpty {
                AppActionButton(
                    title: "分享结构化证据",
                    systemImage: "square.and.arrow.up",
                    shareText: model.exportText
                )
            }

            if model.isSaving {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("正在保存到本机 App Group…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = model.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } header: {
            Text("当前会话")
        } footer: {
            Text("所有证据项都需要明确标记；外部候选还必须由 Candidate receipt 核对产物身份与证据上下文，待核对状态不会形成通过结论。")
        }
    }

    private func evidenceStepRow(
        _ step: ReleaseEvidenceStep,
        runID: UUID
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: outcomeSymbol(step.outcome))
                .foregroundStyle(outcomeColor(step.outcome))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(step.scope.title)
                    .font(.subheadline.weight(.semibold))
                Text(step.scope.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !step.note.isEmpty {
                    Text(step.note)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 8)

            Menu {
                ForEach(ReleaseEvidenceOutcome.allCases) { outcome in
                    Button {
                        model.setOutcome(outcome, for: step.scope, in: runID)
                    } label: {
                        Label(outcome.title, systemImage: outcomeSymbol(outcome))
                    }
                }
            } label: {
                Text(step.outcome.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(outcomeColor(step.outcome))
            }
            .disabled(model.isSaving)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.scope.title)，\(step.outcome.title)")
    }

    private var historySection: some View {
        Section {
            if model.runs.isEmpty {
                Text(model.isLoading ? "正在读取本机证据…" : "尚无已保存的证据会话。")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(model.runs) { run in
                    Button {
                        model.selectedRunID = run.id
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: outcomeSymbol(run.outcome))
                                .foregroundStyle(outcomeColor(run.outcome))
                            VStack(alignment: .leading, spacing: 3) {
                                Text("\(run.lane.title) · \(run.candidateID)")
                                    .foregroundStyle(.primary)
                                Text(
                                    "\(run.profile.title) · \(run.updatedAt.formatted(date: .abbreviated, time: .shortened))"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 8)
                            if run.id == model.selectedRunID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("历史会话（最多保留 50 条）")
        }
    }

    private var boundarySection: some View {
        Section {
            Text(
                "日常 Beta 的通过证据可以被外部候选引用。只有 Candidate receipt 核对产物身份、行为契约、验证档位、设备/系统、候选绑定和时效后，引用才可视为当前证据；新构建只能作为比较基线，必须刷新当前变更与外部候选专属检查。"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        } header: {
            Text("证据边界")
        } footer: {
            Text("本页面不会替代 CI、独立质量复核、Product Gate、Release Pass 或 App Store Connect 操作。")
        }
    }

    private func outcomeSymbol(_ outcome: ReleaseEvidenceOutcome) -> String {
        switch outcome {
        case .pass:
            return "checkmark.circle.fill"
        case .partial:
            return "circle.lefthalf.filled"
        case .fail:
            return "xmark.circle.fill"
        case .inconclusive:
            return "questionmark.circle.fill"
        case .notRun:
            return "circle"
        }
    }

    private func outcomeColor(_ outcome: ReleaseEvidenceOutcome) -> Color {
        switch outcome {
        case .pass:
            return .primary
        case .partial, .inconclusive:
            return .orange
        case .fail:
            return .red
        case .notRun:
            return .secondary
        }
    }

    private func promotionDescription(_ mode: ReleaseEvidencePromotionMode) -> String {
        switch mode {
        case .pendingArtifactMatch:
            return "此会话沿用了日常 Beta 的记录，但当前构建的 archive / package 身份尚未核对；App 内结论保持为部分完成。"
        case .contractBaseline:
            return "日常 Beta 证据仅作为同版本合同基线；当前构建仍需独立完成增量检查。"
        case .exactArtifact:
            return "产物身份已核对一致；外部候选专属检查仍需单独完成。"
        }
    }
}

#Preview {
    NavigationStack {
        ReleaseEvidenceView()
    }
}
