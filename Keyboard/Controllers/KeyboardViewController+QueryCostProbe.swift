#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import KeyboardCore
    import UIKit

    extension KeyboardViewController {
        func installQueryCostProbeControlsIfNeeded() {
            guard queryCostControls == nil else { return }
            let controls = UIStackView()
            controls.axis = .horizontal
            controls.spacing = 4
            controls.distribution = .fillEqually
            controls.backgroundColor = .secondarySystemBackground
            controls.layer.cornerRadius = 4
            let titles = ["观测成本", "序列边界", "成本取证", "时间锚点"]
            let selectors = [
                #selector(armQueryCostProbe), #selector(markQueryCostSequence), #selector(exportQueryCostProbe),
                #selector(emitQueryCostClockAnchor),
            ]
            for (title, selector) in zip(titles, selectors) {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 11)
                button.titleLabel?.numberOfLines = 1
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.minimumScaleFactor = 0.8
                button.addTarget(self, action: selector, for: .touchUpInside)
                controls.addArrangedSubview(button)
            }
            view.addSubview(controls)
            queryCostControls = controls
            let observer = QueryCostTouchObserver(target: nil, action: nil)
            observer.configure(excluding: controls)
            view.addGestureRecognizer(observer)
            queryCostTouchObserver = observer
        }

        /// Inspect the owned UIControl tree, including invisible key touch cells.
        /// The inspector never reads text or sends actions; excess topology is unknown.
        private var queryCostTouchIdle: Bool {
            guard queryCostTouchObserver?.isIdle == true else { return false }
            var pending = [view!]
            var visited = 0
            while let node = pending.popLast() {
                if node === queryCostControls { continue }
                visited += 1
                guard visited <= 4096 else { return false }
                if let control = node as? UIControl, control.isTracking { return false }
                pending.append(contentsOf: node.subviews)
            }
            return keyPressFeedbackEmittedButtonIDs.isEmpty
        }
        private var queryCostEligible: Bool {
            let elapsed = CACurrentMediaTime() - (lastInputCompletionTime ?? 0)
            return elapsed >= 2 && queryCostTouchIdle
                && typoCorrectionRecallCoordinator.queryCostCallbacksQuiescent
        }
        @objc private func armQueryCostProbe() {
            let coordinator = typoCorrectionRecallCoordinator
            let facade =
                queryCostDebugFacadeScope()
                ?? .unavailable()
            let scope = QueryCostMemoryProbe.Scope(
                coordinatorOrdinal: coordinator.probeCoordinatorOrdinal,
                facade: facade, fullAccess: hasFullAccess)
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: CACurrentMediaTime() - (lastInputCompletionTime ?? 0) >= 2,
                touchIdle: { self.queryCostTouchIdle },
                callbacksIdle: { coordinator.queryCostCallbacksQuiescent })
            let result = coordinator.queryCostProbe.arm(scope, eligible: eligibility.isEligible)
            QueryCostArmDiagnostic.publish(
                QueryCostArmDiagnostic(result: result, eligibility: eligibility, scope: scope))
            (queryCostControls?.arrangedSubviews.first as? UIButton)?.setTitle(
                result == .armed ? "已观测" : "不可启用", for: .normal)
        }
        @objc private func markQueryCostSequence() {
            let probe = typoCorrectionRecallCoordinator.queryCostProbe
            probe.verifyScope(facade: queryCostDebugFacadeScope(), fullAccess: hasFullAccess)
            if probe.scope?.coordinatorOrdinal != typoCorrectionRecallCoordinator.probeCoordinatorOrdinal {
                probe.invalidate(.scopeChange)
            }
            let accepted: Bool
            if queryCostSequenceOpen {
                accepted = probe.endSequence(eligible: queryCostEligible)
                if accepted {
                    queryCostSequenceOpen = false
                    queryCostSequenceOrdinal += 1
                }
            } else {
                accepted = probe.beginSequence(
                    ordinal: queryCostSequenceOrdinal,
                    fixture: (queryCostSequenceOrdinal - 1) % 6 + 1,
                    arm: queryCostSequenceOrdinal <= 6 ? 1 : 2, eligible: queryCostEligible)
                if accepted { queryCostSequenceOpen = true }
            }
            let title = accepted ? (queryCostSequenceOpen ? "结束序列" : "开始序列") : "边界拒绝"
            (queryCostControls?.arrangedSubviews[1] as? UIButton)?.setTitle(title, for: .normal)
        }
        @objc private func emitQueryCostClockAnchor() {
            let result = queryCostClockAnchor.emitNext(eligible: queryCostEligible)
            let title: String
            switch result {
            case .firstEmitted: title = "锚点一已发"
            case .secondEmitted: title = "锚点二已发"
            case .invalid: title = "锚点无效"
            }
            // This control emits metadata only; it never arms or queries the probe.
            (queryCostControls?.arrangedSubviews[3] as? UIButton)?.setTitle(title, for: .normal)
        }
        @objc private func exportQueryCostProbe() {
            let coordinator = typoCorrectionRecallCoordinator
            coordinator.queryCostProbe.verifyScope(
                facade: queryCostDebugFacadeScope(), fullAccess: hasFullAccess,
                coordinatorOrdinal: coordinator.probeCoordinatorOrdinal)
            guard let snapshot = coordinator.queryCostProbe.freeze(callbacksQuiescent: queryCostEligible) else {
                return
            }
            snapshot.withUnsafeBytes { bytes in
                guard let address = bytes.baseAddress else { return }
                // All probe locks released; pointer must be copied before this borrow ends.
                queryCostProbeExportReady(address, bytes.count)
            }
            (queryCostControls?.arrangedSubviews[2] as? UIButton)?.setTitle(
                snapshot.isIncomplete ? "部分证据" : "已冻结", for: .normal)
        }
    }
    /// Passive DEBUG touch accounting also covers candidate cells and gesture-owned views.
    /// It never recognizes an action, cancels or delays a touch, or stores touch content.
    /// Unknown/reset/capacity state is sticky; control-button touches are excluded.
    final class QueryCostTouchObserver: UIGestureRecognizer, UIGestureRecognizerDelegate {
        private weak var controls: UIView?
        private var ledger = QueryCostTouchLedger()
        var isIdle: Bool { ledger.isIdle }
        private func isOwnControl(_ touch: UITouch) -> Bool {
            guard let touched = touch.view, let controls else { return false }
            return touched.isDescendant(of: controls)
        }
        func configure(excluding controls: UIView) {
            self.controls = controls
            cancelsTouchesInView = false
            delaysTouchesBegan = false
            delaysTouchesEnded = false
            delegate = self
        }
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            QueryCostTouchLedger.shouldObserve(isOwnControl: isOwnControl(touch))
        }
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool { true }
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            for touch in touches {
                ledger.begin(ObjectIdentifier(touch), isOwnControl: isOwnControl(touch))
            }
        }
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) { retire(touches) }
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) { retire(touches) }
        override func reset() {
            super.reset()
            ledger.reset()
        }
        private func retire(_ touches: Set<UITouch>) {
            for touch in touches { ledger.retire(ObjectIdentifier(touch)) }
            if ledger.activeCount == 0 { state = .failed }
        }
    }

    @inline(never)
    func queryCostProbeExportReady(_ address: UnsafeRawPointer, _ byteCount: Int) {
        withExtendedLifetime(address) {}
        withExtendedLifetime(byteCount) {}
    }
#endif
