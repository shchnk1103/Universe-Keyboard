#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import KeyboardCore

    /// Same-attempt arm inputs only. No input text, engine handles, or persistence.
    nonisolated struct QueryCostArmDiagnostic: Sendable {
        enum Check: UInt64, Sendable { case skipped = 0, failed = 1, passed = 2 }
        struct Eligibility: Sendable {
            let elapsed: Check
            let touch: Check
            let callbacks: Check
            var isEligible: Bool { callbacks == .passed }

            /// Preserve the original short circuit; ledger checks may have side effects.
            @MainActor static func sample(
                elapsedIdle: Bool, touchIdle: () -> Bool, callbacksIdle: () -> Bool
            ) -> Self {
                guard elapsedIdle else {
                    return Self(elapsed: .failed, touch: .skipped, callbacks: .skipped)
                }
                guard touchIdle() else {
                    return Self(elapsed: .passed, touch: .failed, callbacks: .skipped)
                }
                return Self(elapsed: .passed, touch: .passed, callbacks: callbacksIdle() ? .passed : .failed)
            }
        }
        static let magic: UInt64 = 0x5143_4144_4941_4731
        static let byteCount = 128
        let words: [UInt64]
        @MainActor private(set) static var latest: Self?

        init(result: QueryCostMemoryProbe.ArmResult, eligibility: Eligibility, scope: QueryCostMemoryProbe.Scope) {
            let code: UInt64
            switch result {
            case .armed: code = 1
            case .rejected: code = 2
            case .alreadyAttempted: code = 3
            }
            var uuid = scope.runID.uuid
            let identity = withUnsafeBytes(of: &uuid) { bytes in
                (0..<2).map { word in
                    (0..<8).reduce(UInt64(0)) { $0 | UInt64(bytes[word * 8 + $1]) << (8 * $1) }
                }
            }
            words = [
                Self.magic, 2, 16, code, eligibility.elapsed.rawValue, eligibility.touch.rawValue,
                eligibility.callbacks.rawValue, eligibility.isEligible ? 2 : 1, scope.fullAccess ? 2 : 1,
                scope.coordinatorOrdinal, scope.facade.lifetimeOrdinal, scope.facade.schema.rawValue,
                identity[0], identity[1], scope.facade.kind.rawValue, scope.facade.facadeOrdinal,
            ]
        }
        private init(words: [UInt64]) { self.words = words }
        var encoded: Data {
            words.map { $0.littleEndian }.withUnsafeBytes { Data($0) }
        }
        static func decode(_ data: Data) -> Self? {
            guard data.count == byteCount else { return nil }
            let bytes = [UInt8](data)
            let words = (0..<16).map { word in
                (0..<8).reduce(UInt64(0)) { $0 | UInt64(bytes[word * 8 + $1]) << (8 * $1) }
            }
            guard words[0] == magic, words[1] == 2, words[2] == 16,
                (1...3).contains(words[3]), words[7] == 1 || words[7] == 2,
                words[8] == 1 || words[8] == 2, words[11] <= 1, words[14] <= 3
            else { return nil }
            if words[3] == 1 {
                guard words[7] == 2, words[8] == 2, words[9] != 0, words[10] != 0,
                    words[11] == 1, words[14] == 1 || words[14] == 2, words[15] != 0
                else { return nil }
            }
            let checks = Array(words[4...6])
            guard
                checks == [1, 0, 0] || checks == [2, 1, 0]
                    || checks == [2, 2, 1] || checks == [2, 2, 2],
                (words[7] == 2) == (checks == [2, 2, 2])
            else { return nil }
            return Self(words: words)
        }
        @MainActor static func publish(_ snapshot: Self) {
            latest = snapshot
            let data = snapshot.encoded
            data.withUnsafeBytes { bytes in
                guard let address = bytes.baseAddress else { return }
                // The debugger may copy exactly 128 bytes only during this borrow.
                queryCostArmDiagnosticReady(address, bytes.count)
            }
        }
    }
    @inline(never)
    func queryCostArmDiagnosticReady(_ address: UnsafeRawPointer, _ byteCount: Int) {
        withExtendedLifetime(address) {}
        withExtendedLifetime(byteCount) {}
    }
#endif
