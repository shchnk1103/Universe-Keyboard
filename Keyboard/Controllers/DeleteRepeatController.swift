import Foundation

/// Owns the long-press delete timers so repeated deletion has one lifecycle owner.
///
/// Keep these timing values stable: they are part of the keyboard interaction
/// baseline and changing them would alter the perceived deletion behavior.
@MainActor
final class DeleteRepeatController {
    private static let initialDelay: TimeInterval = 0.5
    private static let repeatInterval: TimeInterval = 0.08

    private var timer: Timer?

    func begin(repeatAction: @escaping @MainActor () -> Void) {
        stop()

        let initialTimer = Timer(timeInterval: Self.initialDelay, repeats: false) {
            [weak self] _ in
            Task { @MainActor [weak self] in
                self?.beginRepeating(action: repeatAction)
            }
        }
        timer = initialTimer
        RunLoop.main.add(initialTimer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func beginRepeating(action: @escaping @MainActor () -> Void) {
        let repeatTimer = Timer(timeInterval: Self.repeatInterval, repeats: true) { _ in
            Task { @MainActor in
                action()
            }
        }
        timer = repeatTimer
        RunLoop.main.add(repeatTimer, forMode: .common)
    }
}
