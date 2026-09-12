import XCTest

@testable import KeyboardCore

final class RimeWanxiangSharedDefaultAdapterTests: XCTestCase {
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
        let rewritten = RimeWanxiangSharedDefaultAdapter.rewritePresetReferences(yaml)
        XCTAssertFalse(rewritten.contains("__include: default:/"))
        XCTAssertTrue(rewritten.contains("__include: wanxiang_preset:/punctuator"))
        XCTAssertTrue(rewritten.contains("__include: wanxiang_preset:/key_binder?"))
        XCTAssertTrue(rewritten.contains("import_preset: wanxiang_preset"))
        XCTAssertFalse(rewritten.contains("import_preset: default"))
    }

    func testApplyCopiesPresetAndLeavesUpstreamDefault() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "wanxiang-preset-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try "config_version: wanxiang\n".write(
            to: root.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try "punctuator:\n  __include: default:/punctuator\n".write(
            to: root.appendingPathComponent("wanxiang.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try "key_binder:\n  import_preset: default\n".write(
            to: root.appendingPathComponent("wanxiang_english.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        try RimeWanxiangSharedDefaultAdapter.apply(in: root)

        XCTAssertEqual(
            try String(contentsOf: root.appendingPathComponent("default.yaml"), encoding: .utf8),
            "config_version: wanxiang\n"
        )
        XCTAssertEqual(
            try String(
                contentsOf: root.appendingPathComponent("wanxiang_preset.yaml"),
                encoding: .utf8
            ),
            "config_version: wanxiang\n"
        )
        let schema = try String(
            contentsOf: root.appendingPathComponent("wanxiang.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(schema.contains("__include: wanxiang_preset:/punctuator"))
        let english = try String(
            contentsOf: root.appendingPathComponent("wanxiang_english.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(english.contains("import_preset: wanxiang_preset"))
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
    }

    func testApplyFailsWhenUpstreamDefaultIsMissing() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "wanxiang-preset-missing-\(UUID().uuidString)",
            isDirectory: true
        )
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertThrowsError(try RimeWanxiangSharedDefaultAdapter.apply(in: root)) { error in
            XCTAssertEqual(
                error as? RimeWanxiangSharedDefaultAdapter.AdapterError,
                .missingUpstreamDefault
            )
        }
    }
}
