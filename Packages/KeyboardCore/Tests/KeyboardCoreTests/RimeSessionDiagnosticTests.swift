import XCTest

@testable import KeyboardCore

final class RimeSessionDiagnosticTests: XCTestCase {
    func testProtocolExistentialUsesConcreteSessionSnapshot() {
        let fake = FakeRimeEngine()
        fake.diagnosticSessionSnapshot = RimeSessionDiagnosticSnapshot(
            identity: 42,
            isValid: true
        )
        let engine: any RimeEngine = fake

        XCTAssertEqual(
            engine.diagnosticSessionSnapshot,
            RimeSessionDiagnosticSnapshot(identity: 42, isValid: true)
        )
    }
}
