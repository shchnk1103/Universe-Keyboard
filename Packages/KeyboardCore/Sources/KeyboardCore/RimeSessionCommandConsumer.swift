import Foundation

/// PB-016 PR-1: MainActor contract for quick-menu session command results.
///
/// The Extension installs its `RimeSessionCommandGateway` as the consumer.
/// KeyboardCore depends only on this contract so `command-*` snapshots
/// published by either owner (thread-affine or MainActor serial) reach the
/// gateway without coupling Core to the App type.
@MainActor
public protocol RimeSessionCommandConsuming: AnyObject {
    /// Delivered on MainActor for every published `command-*` snapshot before
    /// presentation gating, so an expired completion still releases the
    /// in-flight gate instead of being silently coalesced away (§3.2 #2).
    /// `presentationEpoch` is the MainActor presentation epoch at delivery;
    /// the consumer must only rebuild chrome when the completion epoch equals
    /// it (§3.3 alignment rule).
    func consumeCommandResult(_ snapshot: ResponsiveRimeSnapshot, presentationEpoch: UInt64)

    /// Release hook for `cleanupTransientKeyboardState` / `reloadKeyboard` /
    /// fail-closed publication (§3.2 #4/#5/#6): drop the in-flight selection
    /// without waiting for the owner. A late completion then arrives untracked
    /// and is released on arrival without a chrome rebuild or preference
    /// write-back.
    func abandonInFlightSelection()
}
