import CryptoKit
import Foundation
import XCTest

@testable import RimeBridge

final class RimeBuiltinResourceInstallerTests: XCTestCase {
    func testValidClosureInstallsEveryRequiredFileAndKeepsThirdPartyFiles() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
        let shared = rimeRoot.appendingPathComponent("shared", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        let thirdParty = shared.appendingPathComponent("rime_ice.schema.yaml")
        try Data("third-party".utf8).write(to: thirdParty)

        let result = try RimeBuiltinResourceInstaller().install(
            sourceRoot: fixture.source,
            rimeRoot: rimeRoot
        )

        XCTAssertEqual(result.fileCount, RimeBuiltinResourceInstaller.requiredRelativePaths.count)
        XCTAssertEqual(try Data(contentsOf: thirdParty), Data("third-party".utf8))
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: shared.appendingPathComponent(path).path))
        }
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: rimeRoot.appendingPathComponent("builtin-resource-receipt.json").path
            )
        )
    }

    func testCorruptedBundledResourceFailsBeforeLastGoodRuntimeChanges() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let corruptedPath = fixture.source.appendingPathComponent("essay.txt")
        try Data("corrupted".utf8).write(to: corruptedPath)

        let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
        let destination = rimeRoot.appendingPathComponent("shared/essay.txt")
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let lastGood = Data("last-good".utf8)
        try lastGood.write(to: destination)

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(sourceRoot: fixture.source, rimeRoot: rimeRoot)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .byteCountMismatch
            )
        }
        XCTAssertEqual(try Data(contentsOf: destination), lastGood)
    }

    func testSameLengthCorruptionIsRejectedByChecksum() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let url = fixture.source.appendingPathComponent("essay.txt")
        let original = try Data(contentsOf: url)
        try Data(repeating: 0x78, count: original.count).write(to: url)

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: fixture.source)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .checksumMismatch
            )
        }
    }

    func testManifestCannotOmitARequiredRuntimeResource() throws {
        let fixture = try makeFixture(omitting: "stroke.reverse.bin")
        defer { try? FileManager.default.removeItem(at: fixture.root) }

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: fixture.source)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testUnmanifestedResourceIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Data("unexpected".utf8).write(
            to: fixture.source.appendingPathComponent("unexpected.yaml")
        )

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: fixture.source)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testHiddenUnmanifestedResourceIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try Data("unexpected".utf8).write(
            to: fixture.source.appendingPathComponent(".unexpected.yaml")
        )

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: fixture.source)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testMissingProvenanceIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        manifest["sourcePins"] = [:]
        try JSONSerialization.data(withJSONObject: manifest, options: [.sortedKeys]).write(
            to: manifestURL
        )

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: fixture.source)
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .manifestInvalid
            )
        }
    }

    func testInstalledResourceTamperInvalidatesReceipt() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
        let installer = RimeBuiltinResourceInstaller()
        _ = try installer.install(sourceRoot: fixture.source, rimeRoot: rimeRoot)
        let essayURL = rimeRoot.appendingPathComponent("shared/essay.txt")
        let original = try Data(contentsOf: essayURL)
        try Data(repeating: 0x78, count: original.count).write(to: essayURL)

        XCTAssertThrowsError(try installer.validateInstalledResources(rimeRoot: rimeRoot)) {
            error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .checksumMismatch
            )
        }
    }

    func testCorruptPriorReceiptFailsBeforeRuntimeMutation() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
        let sharedRoot = rimeRoot.appendingPathComponent("shared", isDirectory: true)
        let essayURL = sharedRoot.appendingPathComponent("essay.txt")
        try FileManager.default.createDirectory(
            at: essayURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let lastGood = Data("last-good".utf8)
        try lastGood.write(to: essayURL)
        try Data("corrupt-receipt".utf8).write(
            to: rimeRoot.appendingPathComponent("builtin-resource-receipt.json")
        )

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: fixture.source,
                rimeRoot: rimeRoot
            )
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .manifestInvalid
            )
        }
        XCTAssertEqual(try Data(contentsOf: essayURL), lastGood)
    }

    func testOverlayReceiptBindsRequiredRuntimeFiles() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
        let userRoot = rimeRoot.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: userRoot, withIntermediateDirectories: true)
        let installer = RimeBuiltinResourceInstaller()
        _ = try installer.install(sourceRoot: fixture.source, rimeRoot: rimeRoot)
        for path in RimeBuiltinResourceInstaller.requiredOverlayPaths {
            try Data("overlay:\(path)".utf8).write(to: userRoot.appendingPathComponent(path))
        }

        XCTAssertThrowsError(
            try installer.validateInstalledRuntime(rimeRoot: rimeRoot, userDataURL: userRoot)
        )
        try installer.recordOverlayReceipt(rimeRoot: rimeRoot, userDataURL: userRoot)
        XCTAssertNoThrow(
            try installer.validateInstalledRuntime(rimeRoot: rimeRoot, userDataURL: userRoot)
        )
        try Data("changed".utf8).write(
            to: userRoot.appendingPathComponent("luna_pinyin.custom.yaml")
        )
        XCTAssertThrowsError(
            try installer.validateInstalledRuntime(rimeRoot: rimeRoot, userDataURL: userRoot)
        )
    }

    func testEveryFileSwitchFailureRestoresLastGoodRuntime() throws {
        for failurePath in RimeBuiltinResourceInstaller.requiredRelativePaths.sorted() {
            let fixture = try makeFixture()
            defer { try? FileManager.default.removeItem(at: fixture.root) }
            let rimeRoot = fixture.root.appendingPathComponent("runtime", isDirectory: true)
            let sharedRoot = rimeRoot.appendingPathComponent("shared", isDirectory: true)
            try FileManager.default.createDirectory(at: sharedRoot, withIntermediateDirectories: true)
            var lastGood: [String: Data] = [:]
            for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
                let data = Data("last-good:\(path)".utf8)
                let url = sharedRoot.appendingPathComponent(path)
                try FileManager.default.createDirectory(
                    at: url.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data.write(to: url)
                lastGood[path] = data
            }

            XCTAssertThrowsError(
                try RimeBuiltinResourceInstaller(
                    testFailureBeforeInstallingPath: failurePath
                ).install(sourceRoot: fixture.source, rimeRoot: rimeRoot),
                "failurePath=\(failurePath)"
            )
            for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
                XCTAssertEqual(
                    try Data(contentsOf: sharedRoot.appendingPathComponent(path)),
                    lastGood[path],
                    "failurePath=\(failurePath), restoredPath=\(path)"
                )
            }
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: rimeRoot.appendingPathComponent("builtin-resource-receipt.json").path
                ),
                "failurePath=\(failurePath)"
            )
        }
    }

    func testFlattenedMainAppBundleIsReconstructedBeforeValidation() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let bundleRoot = fixture.root.appendingPathComponent("Fixture.bundle", isDirectory: true)
        try FileManager.default.createDirectory(at: bundleRoot, withIntermediateDirectories: true)
        try """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>CFBundleIdentifier</key><string>com.example.RimeBuiltinFixture</string>
        <key>CFBundlePackageType</key><string>BNDL</string>
        </dict></plist>
        """.write(
            to: bundleRoot.appendingPathComponent("Info.plist"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.copyItem(
            at: fixture.source.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName),
            to: bundleRoot.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName)
        )
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
            try FileManager.default.copyItem(
                at: fixture.source.appendingPathComponent(path),
                to: bundleRoot.appendingPathComponent((path as NSString).lastPathComponent)
            )
        }
        let bundle = try XCTUnwrap(Bundle(url: bundleRoot))

        let reconstructed = try RimeConfigManager.stageBundledResourceClosure(from: bundle)
        defer { try? FileManager.default.removeItem(at: reconstructed) }

        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().validateResourceTree(at: reconstructed)
        )
    }

    func testFlattenedBundleRejectsUnmanifestedRimeResource() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let bundleRoot = fixture.root.appendingPathComponent("Extra.bundle", isDirectory: true)
        try makeFlattenedBundle(from: fixture.source, at: bundleRoot)
        try Data("unexpected".utf8).write(to: bundleRoot.appendingPathComponent("unexpected.yaml"))
        let bundle = try XCTUnwrap(Bundle(url: bundleRoot))

        XCTAssertThrowsError(try RimeConfigManager.stageBundledResourceClosure(from: bundle)) {
            error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testFlattenedBundleRejectsUnmanifestedLowercaseTextResource() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let bundleRoot = fixture.root.appendingPathComponent("TextExtra.bundle", isDirectory: true)
        try makeFlattenedBundle(from: fixture.source, at: bundleRoot)
        try Data("unexpected".utf8).write(to: bundleRoot.appendingPathComponent("unexpected.txt"))
        let bundle = try XCTUnwrap(Bundle(url: bundleRoot))

        XCTAssertThrowsError(try RimeConfigManager.stageBundledResourceClosure(from: bundle)) {
            error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testFlattenedBundleRejectsNestedRimeResource() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let bundleRoot = fixture.root.appendingPathComponent("NestedExtra.bundle", isDirectory: true)
        try makeFlattenedBundle(from: fixture.source, at: bundleRoot)
        let nested = bundleRoot.appendingPathComponent("Unexpected", isDirectory: true)
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)
        try Data("unexpected".utf8).write(to: nested.appendingPathComponent("nested.yaml"))
        let bundle = try XCTUnwrap(Bundle(url: bundleRoot))

        XCTAssertThrowsError(try RimeConfigManager.stageBundledResourceClosure(from: bundle)) {
            error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .resourceSetMismatch
            )
        }
    }

    func testOverlayWriteFailureRestoresPreviousFilesAndReceipt() throws {
        enum InjectedFailure: Error { case beforeSecondReplacement }

        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let rimeRoot = fixture.root.appendingPathComponent("Rime", isDirectory: true)
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: fixture.source,
            rimeRoot: rimeRoot
        )
        let userDir = rimeRoot.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        let previous = [
            RimeConfigManager.CustomYamlArtifact(
                filename: "default.custom.yaml",
                content: "patch:\n  schema_list:\n    - schema: luna_pinyin\n"
            ),
            RimeConfigManager.CustomYamlArtifact(
                filename: "luna_pinyin.custom.yaml",
                content: "patch:\n  translator/enable_user_dict: false\n"
            ),
        ]
        for artifact in previous {
            try artifact.content.write(
                to: userDir.appendingPathComponent(artifact.filename),
                atomically: true,
                encoding: .utf8
            )
        }
        try RimeBuiltinResourceInstaller().recordOverlayReceipt(
            rimeRoot: rimeRoot,
            userDataURL: userDir
        )
        let receiptURL = rimeRoot.appendingPathComponent(
            RimeBuiltinResourceInstaller.overlayReceiptFileName
        )
        let previousReceipt = try Data(contentsOf: receiptURL)
        let replacements = previous.map {
            RimeConfigManager.CustomYamlArtifact(
                filename: $0.filename,
                content: $0.content + "# replacement\n"
            )
        }

        XCTAssertThrowsError(
            try RimeConfigManager.replaceCustomYamlArtifacts(
                replacements,
                rimeRoot: rimeRoot,
                beforeReplacing: { filename in
                    if filename == "luna_pinyin.custom.yaml" {
                        throw InjectedFailure.beforeSecondReplacement
                    }
                }
            )
        ) { error in
            XCTAssertTrue(error is InjectedFailure)
        }
        for artifact in previous {
            XCTAssertEqual(
                try String(
                    contentsOf: userDir.appendingPathComponent(artifact.filename),
                    encoding: .utf8
                ),
                artifact.content
            )
        }
        XCTAssertEqual(try Data(contentsOf: receiptURL), previousReceipt)
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().validateInstalledRuntime(
                rimeRoot: rimeRoot,
                userDataURL: userDir
            )
        )
    }

    private func makeFixture(omitting omittedSuffix: String? = nil) throws -> (root: URL, source: URL) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rime-builtin-installer-tests-\(UUID().uuidString)",
            isDirectory: true
        )
        let source = root.appendingPathComponent("RimeBuiltin", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)

        var entries: [[String: Any]] = []
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths.sorted() {
            guard omittedSuffix == nil || !path.hasSuffix(omittedSuffix!) else { continue }
            let data = Data("fixture:\(path)".utf8)
            let url = source.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url)
            entries.append([
                "path": path,
                "byteCount": data.count,
                "sha256": SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
                "role": expectedRole(for: path),
            ])
        }
        let manifest: [String: Any] = [
            "formatVersion": 2,
            "generationID": "fixture-v1",
            "sourcePins": [
                "essay": String(repeating: "1", count: 40),
                "lunaPinyin": String(repeating: "2", count: 40),
                "opencc": String(repeating: "3", count: 40),
                "prelude": String(repeating: "4", count: 40),
                "stroke": String(repeating: "5", count: 40),
            ],
            "generators": [
                "rimeDeployer": [
                    "version": "fixture",
                    "sha256": String(repeating: "a", count: 64),
                ],
                "opencc": [
                    "version": "fixture",
                    "sourceRevision": String(repeating: "3", count: 40),
                ],
            ],
            "reproducibility": [
                "host": "fixture-host",
                "command": "fixture-command",
                "cleanOutputSHA256A": String(repeating: "b", count: 64),
                "cleanOutputSHA256B": String(repeating: "b", count: 64),
            ],
            "overlayPolicy": [
                "identifier": "universe-luna-overlay-v1",
                "requiredFiles": ["default.custom.yaml", "luna_pinyin.custom.yaml"],
            ],
            "entries": entries,
        ]
        try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
            .write(to: source.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName))
        return (root, source)
    }

    private func expectedRole(for path: String) -> String {
        if path.hasSuffix(".bin") { return "generated-rime" }
        if path.hasSuffix(".ocd2") { return "generated-opencc" }
        if path.hasSuffix(".json") { return "opencc-config" }
        if path == "essay.txt" { return "preset-vocabulary" }
        return "source"
    }

    private func makeFlattenedBundle(from source: URL, at bundleRoot: URL) throws {
        try FileManager.default.createDirectory(at: bundleRoot, withIntermediateDirectories: true)
        try """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
        <key>CFBundleIdentifier</key><string>com.example.RimeBuiltinExtraFixture</string>
        <key>CFBundlePackageType</key><string>BNDL</string>
        </dict></plist>
        """.write(
            to: bundleRoot.appendingPathComponent("Info.plist"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.copyItem(
            at: source.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName),
            to: bundleRoot.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName)
        )
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
            try FileManager.default.copyItem(
                at: source.appendingPathComponent(path),
                to: bundleRoot.appendingPathComponent((path as NSString).lastPathComponent)
            )
        }
    }
}
