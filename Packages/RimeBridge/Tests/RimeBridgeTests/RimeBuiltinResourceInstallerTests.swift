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
                "role": "fixture",
            ])
        }
        let manifest: [String: Any] = [
            "formatVersion": 1,
            "generationID": "fixture-v1",
            "sourcePins": [:],
            "generators": [:],
            "entries": entries,
        ]
        try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys])
            .write(to: source.appendingPathComponent(RimeBuiltinResourceInstaller.manifestFileName))
        return (root, source)
    }
}
