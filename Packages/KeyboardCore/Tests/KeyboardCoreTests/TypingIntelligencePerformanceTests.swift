import Synchronization
import XCTest

@testable import KeyboardCore

@available(macOS 15.0, *)
private final class TypingBenchmarkPersistence: Sendable {
    private let state = Mutex((epoch: 0, data: Data?.none))

    var configuration: TypingStatisticsPersistence {
        TypingStatisticsPersistence(
            readEpoch: { self.state.withLock { $0.epoch } },
            readSnapshotData: { self.state.withLock { $0.data } },
            writeSnapshotData: { data in self.state.withLock { $0.data = data } }
        )
    }
}

private final class PerformanceTextInputClient: TextInputClient {
    var hasTextBeforeInput: Bool { false }
    func insertText(_ text: String) {}
    func deleteBackward() {}
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ text: String, selectedRange: Range<Int>) {}
    func unmarkText() {}
}

@available(macOS 15.0, *)
@MainActor
final class TypingIntelligencePerformanceTests: XCTestCase {
    func testClassificationPerformance() {
        let text = String(repeating: "Universe输入😀 123，\n", count: 20)

        measure {
            for _ in 0..<500 {
                _ = TypingStatisticsClassifier.classify(text)
            }
        }
    }

    func testCommittedTextCallbackAndAggregationPerformance() {
        let persistence = TypingBenchmarkPersistence()
        let writer = TypingStatisticsWriter(
            persistence: persistence.configuration,
            automaticallySchedulesFlush: false
        )
        let client = PerformanceTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.inputMode = .english
        controller.onCommittedText = { event in
            writer.record(
                TypingStatisticsClassifier.classify(event.text),
                source: event.source,
                at: Date(timeIntervalSince1970: 0),
                resetEpoch: 0
            )
        }

        measure {
            for _ in 0..<1_000 {
                _ = controller.handle(.insertKey("a"))
            }
        }
        writer.flushSynchronouslyForTesting()
    }
}
