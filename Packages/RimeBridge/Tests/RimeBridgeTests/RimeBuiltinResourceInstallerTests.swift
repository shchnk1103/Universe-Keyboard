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

    func testMissingSourceInputReceiptIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        manifest["sourceInputs"] = [:]
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

    func testPackagedSourceHashMustMatchInputReceipt() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        var sourceInputs = try XCTUnwrap(manifest["sourceInputs"] as? [String: Any])
        var essay = try XCTUnwrap(sourceInputs["essay"] as? [String: Any])
        var files = try XCTUnwrap(essay["files"] as? [[String: Any]])
        files[0]["sha256"] = String(repeating: "f", count: 64)
        essay["files"] = files
        sourceInputs["essay"] = essay
        manifest["sourceInputs"] = sourceInputs
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

    func testIncompleteToolchainReceiptIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        manifest["toolchain"] = [:]
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

    func testEmptyGeneratorCommandArgumentsAreRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        var generators = try XCTUnwrap(manifest["generators"] as? [String: Any])
        var rime = try XCTUnwrap(generators["rimeDeployer"] as? [String: Any])
        rime["commandArguments"] = []
        generators["rimeDeployer"] = rime
        manifest["generators"] = generators
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

    func testGeneratorCommandTemplateTamperingIsRejected() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        var generators = try XCTUnwrap(manifest["generators"] as? [String: Any])
        var openCC = try XCTUnwrap(generators["opencc"] as? [String: Any])
        var commands = try XCTUnwrap(openCC["commandArguments"] as? [[String]])
        commands[0][2] = "/mutable/source/OpenCC"
        openCC["commandArguments"] = commands
        generators["opencc"] = openCC
        manifest["generators"] = generators
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

    func testReproducibilityDigestScopeMustNamePayloadBoundary() throws {
        let fixture = try makeFixture()
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let manifestURL = fixture.source.appendingPathComponent(
            RimeBuiltinResourceInstaller.manifestFileName
        )
        var manifest = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: manifestURL)) as? [String: Any]
        )
        var reproducibility = try XCTUnwrap(manifest["reproducibility"] as? [String: Any])
        reproducibility["digestScope"] = "whole-receipt"
        manifest["reproducibility"] = reproducibility
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
        XCTAssertNoThrow(
            try installer.validateInstalledRuntimeAuthorization(
                rimeRoot: rimeRoot,
                userDataURL: userRoot
            )
        )
        try Data("changed".utf8).write(
            to: userRoot.appendingPathComponent("luna_pinyin.custom.yaml")
        )
        XCTAssertThrowsError(
            try installer.validateInstalledRuntime(rimeRoot: rimeRoot, userDataURL: userRoot)
        )
        XCTAssertThrowsError(
            try installer.validateInstalledRuntimeAuthorization(
                rimeRoot: rimeRoot,
                userDataURL: userRoot
            )
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

    func testOverlayFailureDuringResourceInstallRestoresCompletePreviousGeneration() throws {
        enum InjectedFailure: Error { case beforeSecondReplacement }

        let previousFixture = try makeFixture(generationID: "fixture-v1", contentPrefix: "old")
        defer { try? FileManager.default.removeItem(at: previousFixture.root) }
        let replacementFixture = try makeFixture(generationID: "fixture-v2", contentPrefix: "new")
        defer { try? FileManager.default.removeItem(at: replacementFixture.root) }
        let rimeRoot = previousFixture.root.appendingPathComponent("Rime", isDirectory: true)
        let userDir = rimeRoot.appendingPathComponent("user", isDirectory: true)
        let installer = RimeBuiltinResourceInstaller()
        _ = try installer.install(sourceRoot: previousFixture.source, rimeRoot: rimeRoot)
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        let previousOverlays = [
            RimeConfigManager.CustomYamlArtifact(
                filename: "default.custom.yaml",
                content: "patch:\n  schema_list:\n    - schema: luna_pinyin\n"
            ),
            RimeConfigManager.CustomYamlArtifact(
                filename: "luna_pinyin.custom.yaml",
                content: "patch:\n  translator/enable_user_dict: false\n"
            ),
        ]
        for artifact in previousOverlays {
            try artifact.content.write(
                to: userDir.appendingPathComponent(artifact.filename),
                atomically: true,
                encoding: .utf8
            )
        }
        try installer.recordOverlayReceipt(rimeRoot: rimeRoot, userDataURL: userDir)
        let resourceReceiptURL = rimeRoot.appendingPathComponent(
            RimeBuiltinResourceInstaller.resourceReceiptFileName
        )
        let overlayReceiptURL = rimeRoot.appendingPathComponent(
            RimeBuiltinResourceInstaller.overlayReceiptFileName
        )
        let previousResourceReceipt = try Data(contentsOf: resourceReceiptURL)
        let previousOverlayReceipt = try Data(contentsOf: overlayReceiptURL)

        XCTAssertThrowsError(
            try installer.install(
                sourceRoot: replacementFixture.source,
                rimeRoot: rimeRoot,
                afterInstallingResources: {
                    try RimeConfigManager.replaceCustomYamlArtifacts(
                        previousOverlays.map {
                            RimeConfigManager.CustomYamlArtifact(
                                filename: $0.filename,
                                content: $0.content + "# replacement\n"
                            )
                        },
                        rimeRoot: rimeRoot,
                        beforeReplacing: { filename in
                            if filename == "luna_pinyin.custom.yaml" {
                                throw InjectedFailure.beforeSecondReplacement
                            }
                        }
                    )
                }
            )
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .fileOperationFailed
            )
        }

        XCTAssertEqual(try Data(contentsOf: resourceReceiptURL), previousResourceReceipt)
        XCTAssertEqual(try Data(contentsOf: overlayReceiptURL), previousOverlayReceipt)
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths {
            XCTAssertEqual(
                try Data(contentsOf: rimeRoot.appendingPathComponent("shared/").appendingPathComponent(path)),
                try Data(contentsOf: previousFixture.source.appendingPathComponent(path)),
                "restoredPath=\(path)"
            )
        }
        for artifact in previousOverlays {
            XCTAssertEqual(
                try String(
                    contentsOf: userDir.appendingPathComponent(artifact.filename),
                    encoding: .utf8
                ),
                artifact.content
            )
        }
        XCTAssertNoThrow(
            try installer.validateInstalledRuntime(rimeRoot: rimeRoot, userDataURL: userDir)
        )
    }

    func testMissingSimplificationPreferenceSyncWritesSimplifiedLunaResetAndReceipt() throws {
        let runtime = try makeInstalledRuntimeFixture()
        defer { try? FileManager.default.removeItem(at: runtime.root) }
        let suiteName = "uk.rime.custom-yaml-missing-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        XCTAssertNil(defaults.object(forKey: "rime_simplification"))

        XCTAssertTrue(
            RimeConfigManager.syncCustomYamlFiles(
                defaults: defaults,
                rimeRoot: runtime.rimeRoot
            )
        )
        let lunaBody = try String(
            contentsOf: runtime.userDir.appendingPathComponent("luna_pinyin.custom.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(lunaBody.contains("\"switches/@2/reset\": 1"))
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().validateInstalledRuntime(
                rimeRoot: runtime.rimeRoot,
                userDataURL: runtime.userDir
            )
        )
    }

    func testExplicitTraditionalPreferenceSyncWritesTraditionalLunaResetAndReceipt() throws {
        let runtime = try makeInstalledRuntimeFixture()
        defer { try? FileManager.default.removeItem(at: runtime.root) }
        let suiteName = "uk.rime.custom-yaml-traditional-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(false, forKey: "rime_simplification")

        XCTAssertTrue(
            RimeConfigManager.syncCustomYamlFiles(
                defaults: defaults,
                rimeRoot: runtime.rimeRoot
            )
        )
        let lunaBody = try String(
            contentsOf: runtime.userDir.appendingPathComponent("luna_pinyin.custom.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(lunaBody.contains("\"switches/@2/reset\": 0"))
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().validateInstalledRuntime(
                rimeRoot: runtime.rimeRoot,
                userDataURL: runtime.userDir
            )
        )
    }

    private func makeFixture(
        omitting omittedSuffix: String? = nil,
        generationID: String = "fixture-v1",
        contentPrefix: String = "fixture"
    ) throws -> (root: URL, source: URL) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "rime-builtin-installer-tests-\(UUID().uuidString)",
            isDirectory: true
        )
        let source = root.appendingPathComponent("RimeBuiltin", isDirectory: true)
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)

        var entries: [[String: Any]] = []
        var entryHashes: [String: String] = [:]
        for path in RimeBuiltinResourceInstaller.requiredRelativePaths.sorted() {
            guard omittedSuffix == nil || !path.hasSuffix(omittedSuffix!) else { continue }
            let data = Data("\(contentPrefix):\(path)".utf8)
            let url = source.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url)
            let sha256 = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            entryHashes[path] = sha256
            entries.append([
                "path": path,
                "byteCount": data.count,
                "sha256": sha256,
                "role": expectedRole(for: path),
            ])
        }
        func input(_ path: String, entryPath: String? = nil) -> [String: Any] {
            [
                "path": path,
                "sha256": entryHashes[entryPath ?? path] ?? String(repeating: "c", count: 64),
            ]
        }
        let manifest: [String: Any] = [
            "formatVersion": 3,
            "generationID": generationID,
            "sourcePins": [
                "essay": String(repeating: "1", count: 40),
                "lunaPinyin": String(repeating: "2", count: 40),
                "opencc": String(repeating: "3", count: 40),
                "prelude": String(repeating: "4", count: 40),
                "stroke": String(repeating: "5", count: 40),
            ],
            "sourceInputs": [
                "essay": [
                    "repository": "https://github.com/rime/rime-essay.git",
                    "revision": String(repeating: "1", count: 40),
                    "files": [input("essay.txt")],
                ],
                "lunaPinyin": [
                    "repository": "https://github.com/rime/rime-luna-pinyin.git",
                    "revision": String(repeating: "2", count: 40),
                    "files": [
                        input("luna_pinyin.dict.yaml"),
                        input("luna_pinyin.schema.yaml"),
                        input("pinyin.yaml"),
                    ],
                ],
                "opencc": [
                    "repository": "https://github.com/BYVoid/OpenCC.git",
                    "revision": String(repeating: "3", count: 40),
                    "files": [
                        input("data/config/s2t.json", entryPath: "opencc/s2t.json"),
                        input("data/config/t2hk.json", entryPath: "opencc/t2hk.json"),
                        input("data/config/t2s.json", entryPath: "opencc/t2s.json"),
                        input("data/config/t2tw.json", entryPath: "opencc/t2tw.json"),
                        input("data/dictionary/HKVariants.txt"),
                        input("data/dictionary/STCharacters.txt"),
                        input("data/dictionary/STPhrases.txt"),
                        input("data/dictionary/TSCharacters.txt"),
                        input("data/dictionary/TSPhrases.txt"),
                        input("data/dictionary/TWVariants.txt"),
                    ],
                ],
                "prelude": [
                    "repository": "https://github.com/rime/rime-prelude.git",
                    "revision": String(repeating: "4", count: 40),
                    "files": [
                        input("default.yaml"), input("key_bindings.yaml"),
                        input("punctuation.yaml"), input("symbols.yaml"),
                    ],
                ],
                "stroke": [
                    "repository": "https://github.com/rime/rime-stroke.git",
                    "revision": String(repeating: "5", count: 40),
                    "files": [input("stroke.dict.yaml"), input("stroke.schema.yaml")],
                ],
            ],
            "generators": [
                "rimeDeployer": [
                    "version": "fixture",
                    "sha256": String(repeating: "a", count: 64),
                    "sourceRepository": "https://github.com/rime/librime.git",
                    "commandArguments": ["rime-a", "rime-b"].flatMap { run in
                        ["luna_pinyin.schema.yaml", "stroke.schema.yaml"].map { schema in
                            [
                                "fixture-rime-deployer", "--compile",
                                "<work-root>/\(run)/shared/\(schema)",
                                "<work-root>/\(run)/user", "<work-root>/\(run)/shared",
                                "<work-root>/\(run)/staging",
                            ]
                        }
                    },
                ],
                "opencc": [
                    "version": "fixture",
                    "sourceRepository": "https://github.com/BYVoid/OpenCC.git",
                    "sourceRevision": String(repeating: "3", count: 40),
                    "commandArguments": ["opencc-a", "opencc-b"].flatMap { run in
                        [
                            [
                                "fixture-cmake", "-S", "<pinned-source-root>/OpenCC", "-B",
                                "<work-root>/\(run)", "-DCMAKE_BUILD_TYPE=Release",
                                "-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF",
                            ],
                            [
                                "fixture-cmake", "--build", "<work-root>/\(run)", "--target",
                                "Dictionaries", "-j", "8",
                            ],
                        ]
                    },
                ],
            ],
            "toolchain": Dictionary(
                uniqueKeysWithValues: [
                    "bash", "cmake", "cxxCompiler", "generationScript", "openccPython", "python3",
                ].map { key in
                    (
                        key,
                        [
                            "path": "fixture-\(key)",
                            "version": "fixture",
                            "sha256": String(repeating: "d", count: 64),
                        ]
                    )
                }
            ),
            "reproducibility": [
                "hostOSVersion": "fixture-os",
                "hostOSBuild": "fixture-build",
                "hostArchitecture": "fixture-architecture",
                "command":
                    "scripts/generate_builtin_rime_resources.sh <pinned-source-root> <output-root>",
                "digestScope": "payload-tree-excluding-manifest",
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

    private func makeInstalledRuntimeFixture() throws -> (
        root: URL, rimeRoot: URL, userDir: URL
    ) {
        let fixture = try makeFixture()
        let rimeRoot = fixture.root.appendingPathComponent("Rime", isDirectory: true)
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: fixture.source,
            rimeRoot: rimeRoot
        )
        return (
            root: fixture.root,
            rimeRoot: rimeRoot,
            userDir: rimeRoot.appendingPathComponent("user", isDirectory: true)
        )
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
