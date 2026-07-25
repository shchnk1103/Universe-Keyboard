import Foundation

/// Presentation-only keys for activation Help packaging (`PD-HELP-TIPKIT-001`).
/// Separate from checklist affirmations — Welcome-seen is not activation success.
nonisolated enum ActivationPresentationStorage {
    /// Soft first-run Welcome has been shown and dismissed (Start, Skip, or swipe).
    static let welcomeSeenKey = "activation_welcome_seen"
}

/// Pure activation checklist state for Guide onboarding.
///
/// Product source: `docs/ONBOARDING_ACTIVATION.md`.
/// The main App must not invent a live Extension Full Access flag; observation and
/// weak user affirmations are modeled separately.
///
/// Marked `nonisolated` so TipKit `Tip` definitions (nonisolated protocol) and unit
/// tests can read the same pure model without MainActor hops.
nonisolated struct ActivationChecklistState: Equatable, Sendable {
    enum Step: Int, CaseIterable, Equatable, Sendable {
        case addKeyboard
        case fullAccess
        case prepareResources
        case firstInput
    }

    enum FullAccessPresentation: Equatable, Sendable {
        case unknown
        case userAffirmed
        case sharedDataUnavailable
        case sharedCapabilityOK
    }

    /// Recommended first-run scheme (`PD-HELP-J3-RESOURCES-001`).
    static let recommendedSchemaID = "rime_ice"
    static let builtinSchemaID = "luna_pinyin"

    var keyboardAddedAffirmed: Bool
    var fullAccess: FullAccessPresentation
    /// Active keyboard schema id (`rime_active_schema`).
    var activeSchemaID: String
    /// Whether the **active** schema is installed on device.
    var activeSchemaInstalled: Bool
    var rimeDeployed: Bool
    var isDeploying: Bool
    var deploymentFailed: Bool
    var firstInputAffirmed: Bool

    /// First incomplete step in the product-required order, if any.
    var nextStep: Step? {
        if !keyboardAddedAffirmed { return .addKeyboard }
        if !isFullAccessSatisfiedForProgress { return .fullAccess }
        if !isResourcesReadyForProgress { return .prepareResources }
        if !firstInputAffirmed { return .firstInput }
        return nil
    }

    var isFullyActivated: Bool {
        nextStep == nil
    }

    /// Whether the top-level **帮助** tab should be visible (`PD-HELP-TIPKIT-001` P2).
    var shouldShowHelpTab: Bool {
        if nextStep != nil { return true }
        if fullAccess == .sharedDataUnavailable { return true }
        if deploymentFailed { return true }
        if isDeploying { return true }
        if !rimeDeployed { return true }
        if !activeSchemaInstalled { return true }
        return false
    }

    /// Full Access step is complete only when not blocked by shared-data failure
    /// and either user-affirmed or positively observed.
    var isFullAccessSatisfiedForProgress: Bool {
        switch fullAccess {
        case .sharedDataUnavailable:
            return false
        case .userAffirmed, .sharedCapabilityOK:
            return true
        case .unknown:
            return false
        }
    }

    /// J3 complete: active scheme installed + deploy succeeded, not failed/in-progress.
    /// (`PD-HELP-J3-RESOURCES-001`)
    var isResourcesReadyForProgress: Bool {
        activeSchemaInstalled
            && rimeDeployed
            && !deploymentFailed
            && !isDeploying
    }

    func statusTitle(for step: Step) -> String {
        switch step {
        case .addKeyboard:
            return keyboardAddedAffirmed ? "已确认添加" : "待完成"
        case .fullAccess:
            switch fullAccess {
            case .unknown:
                return "待完成"
            case .userAffirmed:
                return "已按你的确认开启"
            case .sharedDataUnavailable:
                return "共享数据不可用"
            case .sharedCapabilityOK:
                return "共享能力可用"
            }
        case .prepareResources:
            if isDeploying { return "准备中" }
            if deploymentFailed { return "准备失败" }
            if !activeSchemaInstalled { return "方案未安装" }
            if !rimeDeployed { return "待部署" }
            return "已就绪"
        case .firstInput:
            return firstInputAffirmed ? "已确认" : "待验证"
        }
    }

    func isStepComplete(_ step: Step) -> Bool {
        switch step {
        case .addKeyboard:
            return keyboardAddedAffirmed
        case .fullAccess:
            return isFullAccessSatisfiedForProgress
        case .prepareResources:
            return isResourcesReadyForProgress
        case .firstInput:
            return firstInputAffirmed
        }
    }
}

/// Canonical activation copy. `nonisolated` so TipKit tips can share the same strings.
nonisolated enum ActivationCopy {
    static let valueLocal = "本地 RIME 中文输入，在设备上完成。"
    static let privacyNoUpload = "输入内容、候选与上下文不会上传给开发者。"
    static let fullAccessPurpose =
        "「允许完全访问」用于访问主 App 与键盘共享的本地数据（方案、设置、本地学习等）。"
    static let fullAccessNotUpload = "不用于把按键发送到服务器，也不用于广告跟踪。"
    static let systemLimitation =
        "系统不允许 App 代替你添加键盘或打开完全访问，需要你在「设置」中完成。"
    static let degradedBasicTyping =
        "未开启完全访问时，基本输入通常仍可用；按键震动等共享反馈及其他共享功能可能不可用或不可靠。"
    static let mainAppPreparesResources =
        "输入方案由主 App 准备；键盘扩展不会在输入时自行部署。"
    static let fallbackNotReady =
        "若候选异常有限，可能处于安全降级模式，不代表所选方案已完全就绪。"
    static let liveStateUnknown =
        "主 App 无法在键盘运行前始终得知完全访问的实时状态；请以实际能否使用共享功能为准。"

    static let keyboardDisplayName = "Universe Keyboard"

    /// Soft Welcome primary CTA (`PD-HELP-TIPKIT-001` P1).
    static let welcomeStartTitle = "开始设置"
    /// Soft Welcome secondary CTA — leave on Home; Help remains available.
    static let welcomeSkipTitle = "稍后再说"
    static let welcomeHeadline = "启用 Universe Keyboard"

    /// Settings permanent entry title (`PD-HELP-TIPKIT-001` P2).
    static let settingsHelpEntryTitle = "使用帮助与启用指南"
    static let settingsHelpEntrySubtitle = "重看启用步骤，不会清除进度"
    /// In-Help re-read banner when checklist is complete.
    static let reReadOnlyBanner =
        "可在此重新查看启用说明（重新走一遍）。默认不会清除你的确认进度或部署状态。"

    static let resourcesRecommendRimeIce = "推荐使用雾凇拼音（开源方案，需接受许可证后下载）。"
    static let resourcesSelectThenPrepare = "点选一个方案后，按提示完成许可证、下载与部署。"
    static let resourcesViewLicenseAndDownload = "查看许可证并下载"
    static let resourcesAcceptLicenseAndDownload = "接受许可证并下载"
    static let resourcesActivateAndDeploy = "设为当前方案并部署"
    static let resourcesOpenFullSettings = "在设置中管理全部方案"

    static func title(for step: ActivationChecklistState.Step) -> String {
        switch step {
        case .addKeyboard: return "添加键盘"
        case .fullAccess: return "允许完全访问"
        case .prepareResources: return "准备输入资源"
        case .firstInput: return "试一次输入"
        }
    }

    static func nextActionTitle(for step: ActivationChecklistState.Step) -> String {
        switch step {
        case .addKeyboard: return "打开设置，添加键盘"
        case .fullAccess: return "打开设置，开启完全访问"
        case .prepareResources: return "在下方选择方案并完成部署"
        case .firstInput: return "到「搜索」试用输入，任意内容均可"
        }
    }

    static let firstInputTryCTA = "去搜索页试用输入"
    static let firstInputTryHint =
        "将打开「搜索」并聚焦输入框。请用地球键切换到 \(keyboardDisplayName)，输入任意内容即可；也可顺便搜索设置项。"
    static let firstInputExample =
        "示例（可选）：输入「你好」或设置名如「模糊」。不必与示例一致。"

    static func displayName(forSchemaID schemaID: String) -> String {
        switch schemaID {
        case "rime_ice": return "雾凇拼音"
        case "luna_pinyin": return "朙月拼音"
        default: return schemaID
        }
    }
}
