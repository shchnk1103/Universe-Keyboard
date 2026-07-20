import Foundation

/// Pure activation checklist state for Guide onboarding.
///
/// Product source: `docs/ONBOARDING_ACTIVATION.md`.
/// The main App must not invent a live Extension Full Access flag; observation and
/// weak user affirmations are modeled separately.
struct ActivationChecklistState: Equatable, Sendable {
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

    var keyboardAddedAffirmed: Bool
    var fullAccess: FullAccessPresentation
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

    var isResourcesReadyForProgress: Bool {
        rimeDeployed && !deploymentFailed && !isDeploying
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
            return rimeDeployed ? "已就绪" : "待准备"
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

enum ActivationCopy {
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
        case .prepareResources: return "在设置中准备输入资源"
        case .firstInput: return "去任意输入框试打 nihao"
        }
    }
}
