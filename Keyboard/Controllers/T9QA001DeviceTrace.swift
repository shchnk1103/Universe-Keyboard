#if DEBUG
    import KeyboardCore
    import QuartzCore
    import UIKit

    /// Opt-in, content-free observations only. No logging, IO, scheduling or input ownership.
    /// Objective-C class methods keep the LLDB entry point independent of Swift frame/module lookup.
    @objc(DebugT9QA001Trace)
    @MainActor
    final class T9QA001DeviceTrace: NSObject {
        static let shared = T9QA001DeviceTrace()
        enum Stage: String {
            case key = "T0_KEY_ENTER", returned = "T1_HANDLE_RETURN", published = "T1_UI_PUBLISH_CALLBACK"
            case refresh = "T3_REFRESH_ENTER", model = "T2_MODEL_CAPTURED", bound = "T4_PATHS_BOUND"
            case label = "T4_LABEL_CONFIGURED", row = "ROW_VISIBILITY_REQUEST"
            case pathLayout = "T5_PATH_LAYOUT", rootLayout = "T5_ROOT_LAYOUT"
            case panelStart = "T6_PANEL_START", panelEnd = "T6_PANEL_COMPLETION", panelStable = "T6_AFTER_COMPLETION",
                human = "T7_HUMAN"
        }
        private struct Entry {
            let sequence: UInt64
            let event: Int
            let stage: Stage
            let milliseconds: Double
            let values: [String: Double]
        }
        private let capacity = 128
        private var entries: [Entry] = []
        private var cursor = 0
        private var dropped = 0
        private var sequence: UInt64 = 0
        private var started: CFTimeInterval = 0
        private var armed = false
        private var keys = 0
        private var event = 0
        private var layoutSamples = 0
        private var cellSamples = 0
        private var animationSerial = 0
        private var observedPanels: Set<ObjectIdentifier> = []
        private var lastGeometry: [String: Double] = [:]
        private weak var owner: KeyboardViewController?

        @objc static func arm() {
            let trace = shared
            trace.entries = []
            trace.entries.reserveCapacity(trace.capacity)
            trace.cursor = 0
            trace.dropped = 0
            trace.sequence = 0
            trace.keys = 0
            trace.event = 0
            trace.animationSerial = 0
            trace.observedPanels = []
            trace.owner = nil
            trace.started = CACurrentMediaTime()
            trace.armed = true
        }
        @objc static func stop() { shared.armed = false }
        @objc static func sawBlank() { shared.observe(visible: false) }
        @objc static func sawVisible() { shared.observe(visible: true) }
        @objc static func report() -> String { shared.export() }

        func begin(owner: KeyboardViewController, event: Int) {
            guard armed, owner.shouldReserveT9PinyinPathBar else { return }
            guard keys < 2 else { armed = false; return }
            if let bound = self.owner, bound !== owner { armed = false; return }
            self.owner = owner
            if let panel = owner.candidateExpandedPanel { observedPanels.insert(ObjectIdentifier(panel)) }
            self.event = event
            keys += 1
            layoutSamples = 0
            cellSamples = 0
            lastGeometry = [:]
            record(.key, owner: owner)
        }

        func record(_ stage: Stage, owner: KeyboardViewController, extra: [String: Double] = [:]) {
            guard armed, keys > 0, self.owner === owner else { return }
            let state = owner.controller.state
            let paths = state.t9PinyinPathState
            var values: [String: Double] = [
                "keyOrdinal": Double(keys), "layoutNineKey": owner.cachedLayoutStyle == .nineKey ? 1 : 0,
                "lettersSurface": state.currentPage == .letters ? 1 : 0, "chinese": state.inputMode == .chinese ? 1 : 0,
                "pendingPunctuation": state.pendingPunctuation == nil ? 0 : 1,
                "pendingKaomoji": state.pendingKaomoji == nil ? 0 : 1,
                "sticky": owner.hasExpandedT9PinyinRowInPresentation ? 1 : 0,
                "revision": Double(state.compositionRevision),
                "rawLength": Double(state.lastRimeOutput?.rawInput?.count ?? -1),
                "corePaths": Double(paths.compactPaths.count),
                "corePathLength": Double(paths.compactPaths.reduce(0) { $0 + $1.displayText.count }),
                "rawGeneration": Double(paths.rawInputGeneration), "provenance": Double(paths.provenanceRevision),
                "candidateCount": Double(state.lastRimeOutput?.candidates.count ?? 0),
                "responsive": owner.controller.isResponsiveRimePipelineEnabled ? 1 : 0,
                // UI callbacks have no native operation ID, even with only one observed key.
                "asyncAttributionUncertain": owner.controller.isResponsiveRimePipelineEnabled ? 1 : 0,
                "panelExpanded": owner.isCandidateExpanded ? 1 : 0,
                "panelPresent": owner.candidateExpandedPanel == nil ? 0 : 1,
                "panelTransitioning": (owner.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?
                    .isTransitioning == true ? 1 : 0,
            ]
            values.merge(extra) { _, new in new }
            sequence &+= 1
            let entry = Entry(
                sequence: sequence, event: event, stage: stage,
                milliseconds: (CACurrentMediaTime() - started) * 1000, values: values)
            if entries.count < capacity {
                entries.append(entry)
            } else {
                entries[cursor] = entry; cursor = (cursor + 1) % capacity; dropped += 1
            }
        }

        func model(_ snapshot: T9CompositionPresentationSnapshot, owner: KeyboardViewController) {
            guard armed, self.owner === owner else { return }
            record(
                .model, owner: owner,
                extra: [
                    "modelRevision": Double(snapshot.revision), "modelPaths": Double(snapshot.paths.count),
                    "modelPathLength": Double(snapshot.paths.reduce(0) { $0 + $1.displayText.count }),
                    "modelRawLength": Double(snapshot.rimeRawInput?.count ?? 0),
                ])
        }

        func bar(_ stage: Stage, bar: T9PinyinPathBarView, label: UILabel? = nil) {
            guard armed, let owner, owner.t9PinyinPathBarView === bar else { return }
            if stage == .label {
                guard cellSamples < 8 else { return }
                cellSamples += 1
                record(
                    stage, owner: owner,
                    extra: [
                        "labelLength": Double(label?.text?.count ?? 0),
                        "labelEmpty": label?.text?.isEmpty == false ? 0 : 1,
                        "labelHidden": label?.isHidden == true ? 1 : 0, "labelAlpha": Double(label?.alpha ?? 0),
                        "labelWidth": Double(label?.bounds.width ?? 0),
                        "labelHeight": Double(label?.bounds.height ?? 0),
                    ])
            } else if stage == .pathLayout {
                layout(stage, owner: owner)
            } else {
                record(stage, owner: owner, extra: viewValues(owner))
            }
        }

        func layout(_ stage: Stage, owner: KeyboardViewController) {
            guard armed, self.owner === owner, layoutSamples < 12 else { return }
            let geometry = viewValues(owner)
            guard geometry != lastGeometry else { return }
            lastGeometry = geometry
            layoutSamples += 1
            record(stage, owner: owner, extra: geometry)
        }

        func panelStart(_ panel: ExpandedCandidatePanelContainerView) -> (serial: Int, event: Int) {
            guard armed, let owner, owner.candidateExpandedPanel === panel else { return (0, 0) }
            if observedPanels.count < 8 { observedPanels.insert(ObjectIdentifier(panel)) }
            animationSerial += 1
            self.panel(panel, stage: .panelStart, origin: (animationSerial, event))
            return (animationSerial, event)
        }

        func panel(
            _ panel: ExpandedCandidatePanelContainerView, stage: Stage, tokenMatches: Bool? = nil,
            origin: (serial: Int, event: Int) = (0, 0)
        ) {
            guard armed, let owner,
                owner.candidateExpandedPanel === panel || observedPanels.contains(ObjectIdentifier(panel))
            else { return }
            var values = viewValues(owner)
            values["animationSerial"] = Double(origin.serial)
            values["animationOriginEvent"] = Double(origin.event)
            values["tokenMatches"] = tokenMatches.map { $0 ? 1 : 0 } ?? -1
            values["panelHeight"] = Double(panel.bounds.height)
            values["revealedHeight"] = Double(panel.revealViewport.bounds.height)
            values["presentedRevealHeight"] = Double(panel.revealViewport.layer.presentation()?.bounds.height ?? -1)
            record(stage, owner: owner, extra: values)
        }

        private func viewValues(_ owner: KeyboardViewController) -> [String: Double] {
            var values =
                owner.t9PinyinPathBarView?.qa001ViewMetrics(in: owner.rootStack, overlay: owner.candidateExpandedPanel)
                ?? [:]
            values["rootHeight"] = Double(owner.rootStack?.bounds.height ?? 0)
            values["requestedHeight"] = Double(owner.keyboardHeightConstraint?.constant ?? 0)
            values["maskPresent"] = owner.rootStack?.layer.mask == nil ? 0 : 1
            return values
        }

        private func observe(visible: Bool) {
            guard armed, let owner else { return }
            var values = viewValues(owner)
            values["humanVisible"] = visible ? 1 : 0
            record(.human, owner: owner, extra: values)
        }

        private func export() -> String {
            let ordered = entries.count < capacity ? entries : Array(entries[cursor...] + entries[..<cursor])
            let rows: [[String: Any]] = ordered.map {
                [
                    "seq": $0.sequence, "event": $0.event, "stage": $0.stage.rawValue, "ms": $0.milliseconds,
                    "metrics": $0.values,
                ]
            }
            // Classification is an evidence triage hint, never a root-cause or device acceptance verdict.
            var hint = "INCONCLUSIVE"
            if dropped == 0, let human = ordered.last(where: { $0.stage == .human && $0.values["humanVisible"] == 0 }),
                human.values["humanVisible"] == 0, human.values["asyncAttributionUncertain"] == 0
            {
                let group = ordered.filter { $0.event == human.event && $0.sequence <= human.sequence }
                let model = group.last { $0.stage == .model }
                if let model, model.values["modelRevision"] != human.values["revision"] {
                    hint = "INCONCLUSIVE"
                } else if model?.values["modelPaths"] == 0 {
                    hint = "DATA_NOT_READY"
                } else if model == nil,
                    (group.last { $0.stage == .returned || $0.stage == .published })?.values["corePaths"] ?? 0 > 0
                {
                    hint = "MODEL_NOT_REFRESHED"
                } else if model?.values["modelPaths"] ?? 0 > 0 {
                    let v = human.values
                    if v["rowHeight"] == 0 || v["hiddenAncestor"] == 1 || v["maskModelContains"] == 0
                        || v["effectiveAlpha"] ?? 1 < 0.01 || v["collectionHeight"] == 0
                        || v["panelModelCoversLabel"] == 1
                    {
                        hint = "VIEW_NOT_VISIBLE"
                    } else if v["boundPaths"] == 0 || (v["visibleCells"] ?? 0 > 0 && v["labelMatchesModel"] == 0) {
                        hint = "LABEL_NOT_UPDATED"
                    }
                }
            }
            let result: [String: Any] = [
                "schema": 1, "armed": armed, "capacity": capacity, "dropped": dropped,
                "keysCaptured": keys, "triageHint": hint, "nativeOperationReturnObserved": false, "records": rows,
            ]
            guard
                let data = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]),
                let text = String(data: data, encoding: .utf8)
            else { return "INCONCLUSIVE" }
            return text
        }
    }
#endif
