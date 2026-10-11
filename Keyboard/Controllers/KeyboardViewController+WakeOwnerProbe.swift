import KeyboardCore
import UIKit

#if DEBUG && KEYBOARD_WAKE_OWNER_PROBE
    extension KeyboardViewController {
        private var wakeProbe: KeyboardWakeOwnerProbe { .shared }

        func installWakeOwnerProbeControls(on bar: CandidateBarView) {
            bar.installWakeOwnerProbeButton(target: self, action: #selector(handleWakeOwnerProbeButton))
            bar.onWakeOwnerProbeTouch = { [weak self] touch, began in
                self?.wakeOwnerProbeTouch(touch, began: began)
            }
            refreshWakeOwnerProbeControls()
        }

        func wakeOwnerProbeTouch(_ identifier: ObjectIdentifier, began: Bool) {
            if began {
                wakeProbeActiveTouches.insert(identifier)
            } else {
                wakeProbeActiveTouches.remove(identifier)
            }
            wakeProbeLastActivity = DispatchTime.now().uptimeNanoseconds
            refreshWakeOwnerProbeControls()
        }

        func refreshWakeOwnerProbeControls() {
            wakeProbeIdleTask?.cancel()
            guard let bar = candidateBar as? CandidateBarView else { return }
            let now = DispatchTime.now().uptimeNanoseconds
            let deadline = wakeProbeLastActivity &+ 2_000_000_000
            let idle = wakeProbeActiveTouches.isEmpty && now >= deadline
            let observing = wakeProbe.isArmed || wakeProbe.isFrozen
            bar.setWakeOwnerProbeButton(
                visible: wakeProbeControlsAvailable
                    && KeyboardWakeOwnerProbe.showsControl(
                        isObserving: observing, hasCandidates: !presentedCandidates.isEmpty,
                        hasActiveTouches: !wakeProbeActiveTouches.isEmpty,
                        elapsedIdleNanoseconds: now >= wakeProbeLastActivity ? now - wakeProbeLastActivity : 0
                    ),
                title: observing ? "取证" : "观测"
            )
            guard wakeProbeControlsAvailable, wakeProbeActiveTouches.isEmpty, !idle else { return }
            let remaining = deadline - now
            wakeProbeIdleTask = Task { @MainActor [weak self] in
                do { try await Task.sleep(nanoseconds: remaining) } catch { return }
                guard !Task.isCancelled else { return }
                self?.refreshWakeOwnerProbeControls()
            }
        }

        func wakeOwnerProbeWillAppear() {
            wakeProbeControlsAvailable = true
            wakeProbeAppearanceOrdinal &+= 1
            recordWakeOwnerProbe(.appearance)
            refreshWakeOwnerProbeControls()
        }

        func wakeOwnerProbeWillDisappear() {
            wakeProbeControlsAvailable = false
            wakeProbeIdleTask?.cancel()
            wakeProbeActiveTouches.removeAll()
            refreshWakeOwnerProbeControls()
        }

        func recordWakeOwnerProbe(_ stage: KeyboardWakeOwnerProbe.Stage) {
            let coordinator = controller?.threadAffineRimeCoordinator
            wakeProbe.record(
                stage: stage,
                coordinatorOrdinal: coordinator?.wakeProbeCoordinatorOrdinal ?? 0,
                appearanceOrdinal: wakeProbeAppearanceOrdinal,
                ownerPresent: coordinator?.wakeProbeOwnerPresent == true
            )
        }

        @objc private func handleWakeOwnerProbeButton() {
            // Never route this control through Core, the proxy or keyboard dismissal.
            if !wakeProbe.isArmed && !wakeProbe.isFrozen {
                _ = wakeProbe.arm()
                recordWakeOwnerProbe(.armed)
                refreshWakeOwnerProbeControls()
                return
            }
            guard let snapshot = wakeProbe.freeze() else { return }
            let words = snapshot.words
            // Freeze releases the Mutex before the debugger's read-only breakpoint.
            words.withUnsafeBytes { bytes in
                guard let address = bytes.baseAddress else { return }
                wakeOwnerProbeExportReady(address, bytes.count)
            }
            refreshWakeOwnerProbeControls()
        }
    }

    /// Exact Debug symbol used for fixed-size memory reads; the borrow must stay in the caller.
    @inline(never)
    func wakeOwnerProbeExportReady(_ address: UnsafeRawPointer, _ byteCount: Int) {
        withExtendedLifetime(address) {}
        withExtendedLifetime(byteCount) {}
    }
#endif
