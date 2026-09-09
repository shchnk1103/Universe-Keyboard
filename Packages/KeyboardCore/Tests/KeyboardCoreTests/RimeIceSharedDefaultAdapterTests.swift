import XCTest

@testable import KeyboardCore

final class RimeIceSharedDefaultAdapterTests: XCTestCase {
    func testRewriteChangesIncludeAndImportPresetOnly() {
        let yaml = """
            punctuator:
              __include: default:/punctuator
              full_shape:
                __include: default:/punctuator/full_shape
            recognizer:
              import_preset: default
            key_binder:
              import_preset: default  # comment
            radical:
              __include: default:/key_binder?
            """
        let rewritten = RimeIceSharedDefaultAdapter.rewritePresetReferences(yaml)
        XCTAssertFalse(rewritten.contains("__include: default:/"))
        XCTAssertTrue(rewritten.contains("__include: rime_ice_preset:/punctuator"))
        XCTAssertTrue(rewritten.contains("__include: rime_ice_preset:/key_binder?"))
        XCTAssertTrue(rewritten.contains("import_preset: rime_ice_preset"))
        XCTAssertFalse(rewritten.contains("import_preset: default"))
    }

    func testApplyCopiesPresetAndLeavesUpstreamDefault() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "ice-preset-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try "config_version: ice\n".write(
            to: root.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try "punctuator:\n  __include: default:/punctuator\n".write(
            to: root.appendingPathComponent("rime_ice.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        try RimeIceSharedDefaultAdapter.apply(in: root)

        XCTAssertEqual(
            try String(contentsOf: root.appendingPathComponent("default.yaml"), encoding: .utf8),
            "config_version: ice\n"
        )
        XCTAssertEqual(
            try String(
                contentsOf: root.appendingPathComponent("rime_ice_preset.yaml"),
                encoding: .utf8
            ),
            "config_version: ice\n"
        )
        let schema = try String(
            contentsOf: root.appendingPathComponent("rime_ice.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(schema.contains("__include: rime_ice_preset:/punctuator"))
    }

    func testApplyFailsWhenUpstreamDefaultIsMissing() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "ice-preset-missing-\(UUID().uuidString)",
            isDirectory: true
        )
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertThrowsError(try RimeIceSharedDefaultAdapter.apply(in: root)) { error in
            XCTAssertEqual(
                error as? RimeIceSharedDefaultAdapter.AdapterError,
                .missingUpstreamDefault
            )
        }
    }
}
