import Foundation
import KeyboardCore

/// PB-016 PR-1: MainActor gateway for quick-menu schema/option commands.
///
/// Contract (design r3 §2.2, arch r3 Note-2): the dual gates and owner
/// readiness are re-queried on **every** dispatch — no mode decision is ever
/// cached. Gate-on work is queued as Sendable items to the owning coordinator;
/// fail-closed (direct-held engine) calls the engine serially on MainActor.
///
/// Transaction lifecycle (§3.2): every path leaving the dispatch/consume stack
/// leaves `isRuntimeResselectionInFlight == false` — the gate never sticks.
@MainActor
final class RimeSessionCommandGateway: RimeSessionCommandConsuming {
    struct Selection: Equatable {
        let id: UUID
        let sessionEpoch: UInt64
    }

    enum DispatchResult {
        case queued(ResponsiveRimeAcceptReceipt)
        case schema(Bool)
        case option(RimeOptionResult)
        case unavailable
    }

    private weak var controller: KeyboardController?

    /// Invoked at most once per tracked selection, only when the
    /// completion epoch equals the presentation epoch (§3.2 #1). The
    /// chrome rebuild itself stays on the realized-selection path;
    /// release paths (#2–#6) must never invoke it.
    var onSelectionCommitted: ((Selection) -> Void)?

    init(controller: KeyboardController) {
        self.controller = controller
    }

    func reselectSchema(requested: String) -> DispatchResult {
        dispatch(.reselectSchema(requested))
    }

    func setOption(name: String, value: Bool) -> DispatchResult {
        dispatch(.setOption(name, value: value))
    }

    /// Begins a tracked selection at the live owner epoch. Fail-closed has
    /// no asynchronous owner work to track, so it starts none.
    func beginSelection() -> Selection? {
        guard let controller else { return nil }
        if let affine = controller.threadAffineRimeCoordinator {
            return beginSelection(sessionEpoch: affine.diagnostics.sessionEpoch)
        }
        if let serial = controller.responsiveRimeCoordinator {
            return beginSelection(sessionEpoch: serial.diagnostics.sessionEpoch)
        }
        return nil
    }

    /// The epoch is the owner epoch at acceptance, not a separate
    /// presentation counter (§3.3: one epoch chain, no second counter).
    @discardableResult
    func beginSelection(sessionEpoch: UInt64) -> Selection? {
        guard selection == nil else { return nil }
        let accepted = Selection(id: UUID(), sessionEpoch: sessionEpoch)
        selection = accepted
        return accepted
    }

    // MARK: RimeSessionCommandConsuming

    func consumeCommandResult(_ snapshot: ResponsiveRimeSnapshot, presentationEpoch: UInt64) {
        // Option results carry no selection lifecycle (§3.1: setOption is
        // non-lifecycle, published in the same epoch); the replayed
        // candidates flow through the ordinary presentation path.
        guard snapshot.schemaSelectionSucceeded != nil else { return }
        // #4/#5/#6 already released: the completion lands untracked.
        guard let tracked = selection else { return }
        // A completion from an older, already-abandoned selection must not
        // release a newer tracked selection.
        guard tracked.sessionEpoch == snapshot.sessionEpoch else { return }
        selection = nil
        // #1 committed / #2 expired: presentation epoch moved on (reload,
        // visibility cleanup, composition reset) → discard without chrome
        // rebuild, without preference write-back, without menu revival.
        if snapshot.schemaSelectionSucceeded == true, tracked.sessionEpoch == presentationEpoch {
            onSelectionCommitted?(tracked)
        }
    }

    /// §3.2 #4/#5/#6: cleanup, direct reload and fail-closed publication
    /// release the gate immediately; the owner result is discarded on
    /// arrival (untracked completion) so the gate can never stick.
    func abandonInFlightSelection() {
        selection = nil
    }

    var isRuntimeResselectionInFlight: Bool { selection != nil }

    /// Test/debug: the tracked selection, if any (§3.2 invariant probe).
    var inFlightSelectionForTesting: Selection? { selection }

    private func dispatch(_ work: ResponsiveRimeWork) -> DispatchResult {
        guard let controller else { return .unavailable }
        // Gate-on, off-main owner: queue behind existing session work.
        if let owner = controller.threadAffineRimeCoordinator {
            guard controller.isResponsiveRimePipelineEnabled,
                controller.isThreadAffineRimeOwnerEnabled,
                owner.isOwnerReady,
                let receipt = owner.scheduleSessionCommand(work)
            else { return .unavailable }
            return .queued(receipt)
        }
        // Gate-on, MainActor serial owner: FIFO drain publishes the result.
        if let owner = controller.responsiveRimeCoordinator {
            guard controller.isResponsiveRimePipelineEnabled,
                !controller.isThreadAffineRimeOwnerEnabled,
                let receipt = owner.scheduleSessionCommand(work)
            else { return .unavailable }
            Task { @MainActor in owner.flushPending() }
            return .queued(receipt)
        }
        // Fail-closed: the MainActor-held engine is the only serial owner;
        // a bridge here would mean the gates flipped after install.
        guard !controller.isResponsiveRimePipelineEnabled,
            !controller.isThreadAffineRimeOwnerEnabled,
            let engine = controller.rimeEngine,
            !(engine is ResponsiveRimeEngineBridge),
            !(engine is ThreadAffineRimeEngineBridge)
        else { return .unavailable }
        switch work {
        case .reselectSchema(let schemaID): return .schema(engine.selectSchema(schemaID))
        case .setOption(let name, let value): return .option(engine.setOption(name, value: value))
        default: return .unavailable
        }
    }

    private(set) var selection: Selection?
}
