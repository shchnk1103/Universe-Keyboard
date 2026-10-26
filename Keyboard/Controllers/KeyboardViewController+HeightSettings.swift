import KeyboardCore
import UIKit

/// 来自当前扩展窗口；screenHeight 是界面方向下的整屏 pt 高，不是键盘自身高度。
struct KeyboardHeightGeometry: Equatable {
    let screenHeight: Double
    let isLandscape: Bool
}

/// 弱引用避免保留已被移除的行/面板；更新时仍使用各自原来的系数和间距。
struct KeyboardRowHeightConstraint {
    weak var constraint: NSLayoutConstraint?
    let rows: CGFloat
    let extraHeight: CGFloat
}

extension KeyboardViewController {
    static var defaultKeyboardHeightWithoutPath: CGFloat {
        CGFloat(KeyboardHeightSettings.defaultRowHeight) * 4 + 74
    }

    func prepareKeyboardHeightForAppearance() {
        isKeyboardHeightManaged = true
        if keyboardHeightNeedsRead {
            keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: keyboardRowHeightSource())
            keyboardHeightNeedsRead = false
            resetKeyboardHeightBudgetTrust()
            keyboardHeightGeometry = nil
            view.alpha = 0
        }
        _ = resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight)
    }

    func currentKeyboardHeightGeometry() -> KeyboardHeightGeometry? {
        if let source = keyboardHeightGeometrySource { return source() }
        guard let scene = view.window?.windowScene else { return nil }
        let orientation: UIInterfaceOrientation
        if #available(iOS 26.0, *) {
            orientation = scene.effectiveGeometry.interfaceOrientation
        } else {
            orientation = scene.interfaceOrientation
        }
        guard orientation.isPortrait || orientation.isLandscape else { return nil }
        let size = scene.screen.bounds.size
        // 整屏边长按界面方向归一化，不能用键盘宽高比或物理设备方向推断。
        let height = orientation.isLandscape ? min(size.width, size.height) : max(size.width, size.height)
        guard height.isFinite, height > 0 else { return nil }
        return KeyboardHeightGeometry(screenHeight: Double(height), isLandscape: orientation.isLandscape)
    }

    @discardableResult
    func resolveKeyboardRowHeight(pathHeight: CGFloat, requestOnly: Bool = false) -> Bool {
        guard let geometry = currentKeyboardHeightGeometry() else {
            deferKeyboardHeightLayout(reason: "waitingForWindowScene")
            return false
        }
        if keyboardHeightGeometry != geometry {
            keyboardHeightGeometry = geometry
            resetKeyboardHeightBudgetTrust()
        }
        let fixedHeight =
            keyboardContentTopInset + candidateBarHeight + keySpacing * 2
            + keyboardGroupSpacing + keyboardContentBottomInset + pathHeight
        do {
            let settings = keyboardHeightAdjustmentSession?.previewSettings ?? keyboardHeightSettings
            let desired = try settings.effectiveRowHeight(
                orientation: geometry.isLandscape ? .landscape : .portrait,
                screenHeight: geometry.screenHeight, fixedHeight: Double(fixedHeight))
            let requested = fixedHeight + CGFloat(desired) * 4
            if keyboardUncompressedHeight != requested {
                // 新请求不能继承旧预算；帧观察在可见窗口首次布局后启动。
                stopKeyboardHeightBudgetFrames()
                keyboardHeightBudgetObservationExhausted = false
                keyboardHeightBudgetExhaustedHeight = nil
                keyboardAcceptedHeight = nil
                keyboardHeightBudgetRequest = KeyboardHeightBudgetRequest(height: requested)
            }
            keyboardUncompressedHeight = requested
            // 采样前只计算请求，不先改行约束再夹回，避免制造额外布局循环。
            if requestOnly { return true }
            var effective = CGFloat(desired)
            if let accepted = keyboardAcceptedHeight {
                let available = ((accepted - fixedHeight) / 4).rounded(.down)
                guard available >= CGFloat(KeyboardHeightSettings.minimumRowHeight) else {
                    deferKeyboardHeightLayout(reason: "hostBudgetBelowMinimum")
                    return false
                }
                effective = min(effective, available)
            }
            keyHeight = effective
            keyboardHeightConstraints.removeAll { $0.constraint == nil }
            for entry in keyboardHeightConstraints {
                let height = effective * entry.rows + entry.extraHeight
                if entry.constraint?.constant != height { entry.constraint?.constant = height }
            }
            recordKeyboardHeightStatus("ready")
            return true
        } catch {
            deferKeyboardHeightLayout(reason: "invalidOrInsufficientGeometry")
            return false
        }
    }

    /// 几何尚不可用时既不请求默认高度，也不展示旧宿主留下的行高。
    private func deferKeyboardHeightLayout(reason: String) {
        view.alpha = 0
        keyboardHeightConstraint?.isActive = false
        recordKeyboardHeightStatus(reason)
    }

    private func recordKeyboardHeightStatus(_ status: String) {
        guard keyboardHeightStatus != status else { return }
        keyboardHeightStatus = status
        Logger.shared.debug("keyboardHeight: \(status)", category: .display)
    }

    func synchronizeKeyboardHeightLayout(isHostLayout: Bool = false) {
        guard isKeyboardHeightManaged, !isUpdatingKeyboardHeight else { return }
        isUpdatingKeyboardHeight = true
        defer { isUpdatingKeyboardHeight = false }
        // 只计算目标，不先修改行约束；低预算隐藏后也必须能重新观察宿主。
        guard resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight, requestOnly: true)
        else { return }
        if isHostLayout, view.window != nil, hostLifecycleRecoveryGate.phase == .visible {
            observeKeyboardHostHeight()
        }
        guard resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight) else { return }
        installPreferredKeyboardHeight()
        installKeyboardUIIfNeeded()
        if isKeyboardUIInstalled { view.alpha = 1 }
    }

    private func observeKeyboardHostHeight() {
        guard let requested = keyboardUncompressedHeight, view.bounds.height > 0 else { return }
        let actual = view.bounds.height
        if actual >= requested {
            stopKeyboardHeightBudgetFrames()
            keyboardHeightBudgetRequest = nil
            keyboardHeightBudgetObservationExhausted = false
            keyboardHeightBudgetExhaustedHeight = nil
            keyboardAcceptedHeight = nil
            return
        }
        guard keyboardAcceptedHeight != actual else { return }
        if keyboardHeightBudgetObservationExhausted {
            // 耗尽只由下方的一次有界恢复处理，布局变化也不能绕过总次数上限。
            return
        }
        if keyboardHeightBudgetRequest == nil {
            // 结算后的新低读数也走同一判据，不能直接采用动画中间值。
            keyboardHeightBudgetRequest = KeyboardHeightBudgetRequest(height: requested)
            keyboardAcceptedHeight = nil
        }
        guard keyboardHeightBudgetFrameObservation == nil else { return }
        keyboardHeightBudgetRequest?.begin(at: keyboardHeightBudgetNow(), height: actual)
        let identity = UUID()
        keyboardHeightBudgetObservationID = identity
        keyboardHeightBudgetFrameObservation = keyboardHeightBudgetFrameSource { [weak self] timestamp in
            guard let self, self.keyboardHeightBudgetObservationID == identity else { return }
            self.observeKeyboardHeightDisplayFrame(at: timestamp)
        }
    }

    private func observeKeyboardHeightDisplayFrame(at timestamp: CFTimeInterval) {
        guard view.window != nil, hostLifecycleRecoveryGate.phase == .visible,
            var request = keyboardHeightBudgetRequest
        else {
            stopKeyboardHeightBudgetFrames()
            return
        }
        let result = request.observe(height: view.bounds.height, at: timestamp)
        keyboardHeightBudgetRequest = request
        switch result {
        case .waiting:
            return
        case .accepted(let height):
            keyboardAcceptedHeight = height < request.height ? height : nil
        case .exhausted:
            // 不采用振荡末值；只给耗尽路径一次延后重观察机会。
            keyboardAcceptedHeight = nil
            keyboardHeightBudgetObservationExhausted = true
            keyboardHeightBudgetExhaustedHeight = view.bounds.height
            keyboardHeightBudgetRequest = nil
            stopKeyboardHeightBudgetFrames()
            synchronizeKeyboardHeightLayout()
            if request.allowsExhaustionRecovery {
                scheduleKeyboardHeightBudgetRecovery(for: request, after: timestamp)
            }
            return
        }
        keyboardHeightBudgetRequest = nil
        stopKeyboardHeightBudgetFrames()
        synchronizeKeyboardHeightLayout()
    }

    /// 仅首次耗尽调用：等待一个66.7ms信任窗口，再开一次原判据窗口；不以旧值相同拒绝恢复。
    private func scheduleKeyboardHeightBudgetRecovery(
        for request: KeyboardHeightBudgetRequest, after timestamp: CFTimeInterval
    ) {
        guard keyboardUncompressedHeight == request.height, keyboardHeightBudgetObservationExhausted,
            view.window != nil, hostLifecycleRecoveryGate.phase == .visible
        else { return }
        let startedAt = timestamp.isFinite ? timestamp : keyboardHeightBudgetNow()
        let identity = UUID()
        var samples = 0
        keyboardHeightBudgetObservationID = identity
        keyboardHeightBudgetFrameObservation = keyboardHeightBudgetFrameSource { [weak self] frameTime in
            guard let self, self.keyboardHeightBudgetObservationID == identity else { return }
            samples += 1
            let elapsed = frameTime - startedAt
            guard self.view.window != nil, self.hostLifecycleRecoveryGate.phase == .visible,
                samples < KeyboardHeightBudgetRequest.maximumFrameSamples,
                !frameTime.isFinite || elapsed <= KeyboardHeightBudgetRequest.maximumObservationDuration
            else {
                self.stopKeyboardHeightBudgetFrames()
                return
            }
            guard frameTime.isFinite, elapsed >= KeyboardHeightBudgetRequest.minimumObservationDuration else { return }
            self.stopKeyboardHeightBudgetFrames()
            self.keyboardHeightBudgetObservationExhausted = false
            self.keyboardHeightBudgetExhaustedHeight = nil
            var recovery = KeyboardHeightBudgetRequest(height: request.height)
            recovery.allowsExhaustionRecovery = false
            self.keyboardHeightBudgetRequest = recovery
            self.observeKeyboardHostHeight()
        }
    }

    func resetKeyboardHeightBudgetTrust() {
        stopKeyboardHeightBudgetFrames()
        keyboardHeightBudgetRequest = nil
        keyboardHeightBudgetObservationExhausted = false
        keyboardHeightBudgetExhaustedHeight = nil
        keyboardAcceptedHeight = nil
        keyboardUncompressedHeight = nil
    }

    private func stopKeyboardHeightBudgetFrames() {
        keyboardHeightBudgetObservationID = nil
        keyboardHeightBudgetFrameObservation?.invalidate()
        keyboardHeightBudgetFrameObservation = nil
    }
}

/// 真实帧时间，不以布局调用次数推断宿主已稳定。时长依据见 ADR 0037。
struct KeyboardHeightBudgetRequest {
    static let minimumObservationDuration: CFTimeInterval = 4.0 / 60.0
    static let stableDuration: CFTimeInterval = 1.0 / 60.0
    static let maximumObservationDuration: CFTimeInterval = 8.0 / 60.0
    static let maximumFrameSamples = 32

    enum Result {
        case waiting
        case accepted(CGFloat)
        case exhausted
    }

    let height: CGFloat
    var allowsExhaustionRecovery = true
    private var startedAt: CFTimeInterval?
    private var changedAt: CFTimeInterval = 0
    private var previousHeight: CGFloat?
    private var samples = 0

    init(height: CGFloat) { self.height = height }

    mutating func begin(at timestamp: CFTimeInterval, height: CGFloat) {
        startedAt = timestamp
        changedAt = timestamp
        previousHeight = height
        samples = 0
    }

    mutating func observe(height actual: CGFloat, at timestamp: CFTimeInterval) -> Result {
        samples += 1
        guard timestamp.isFinite, let startedAt, timestamp >= startedAt else {
            return samples >= Self.maximumFrameSamples ? .exhausted : .waiting
        }
        guard actual.isFinite, actual > 0 else {
            return timestamp - startedAt >= Self.maximumObservationDuration
                || samples >= Self.maximumFrameSamples ? .exhausted : .waiting
        }
        if actual >= height { return .accepted(actual) }
        if previousHeight != actual {
            previousHeight = actual
            changedAt = timestamp
        }
        let elapsed = timestamp - startedAt
        if samples >= 2, elapsed >= Self.minimumObservationDuration,
            timestamp - changedAt >= Self.stableDuration
        {
            return .accepted(actual)
        }
        if elapsed >= Self.maximumObservationDuration || samples >= Self.maximumFrameSamples {
            return .exhausted
        }
        return .waiting
    }
}

@MainActor
protocol KeyboardHeightBudgetFrameObservation: AnyObject {
    func invalidate()
}

typealias KeyboardHeightBudgetFrameHandler = @MainActor (CFTimeInterval) -> Void
typealias KeyboardHeightBudgetFrameSource =
    @MainActor (@escaping KeyboardHeightBudgetFrameHandler) -> any KeyboardHeightBudgetFrameObservation

/// 只在有待判定预算时运行；弱 target 避免 display link / observer 互相保留。
@MainActor
final class KeyboardHeightBudgetDisplayLink: KeyboardHeightBudgetFrameObservation {
    private let handler: KeyboardHeightBudgetFrameHandler
    private var displayLink: CADisplayLink?

    init(handler: @escaping KeyboardHeightBudgetFrameHandler) {
        self.handler = handler
        let target = KeyboardHeightBudgetDisplayLinkTarget()
        target.observer = self
        let link = CADisplayLink(target: target, selector: #selector(KeyboardHeightBudgetDisplayLinkTarget.tick(_:)))
        displayLink = link
        link.add(to: .main, forMode: .common)
    }

    func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
    }

    fileprivate func tick(_ link: CADisplayLink) { handler(link.timestamp) }
}

@MainActor
private final class KeyboardHeightBudgetDisplayLinkTarget: NSObject {
    weak var observer: KeyboardHeightBudgetDisplayLink?

    @objc func tick(_ link: CADisplayLink) {
        guard let observer else {
            link.invalidate()
            return
        }
        observer.tick(link)
    }
}
