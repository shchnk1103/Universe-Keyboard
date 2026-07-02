import Foundation
import XCTest

@testable import EnvironmentDigest

final class EnvironmentDigesterTests: XCTestCase {
    private var roots: [URL] = []

    override func tearDownWithError() throws {
        for root in roots { try? FileManager.default.removeItem(at: root) }
        roots.removeAll()
    }

    func testSchemaManifestIsCanonicalRepeatableAndLocationIndependent() throws {
        let first = try fixture(["rime_ice.schema.yaml": "schema: rime_ice\n"])
        let second = try fixture(["rime_ice.schema.yaml": "schema: rime_ice\n"])
        let a = try digest(.schema, root: first)
        let b = try digest(.schema, root: first)
        let c = try digest(.schema, root: second)
        XCTAssertEqual(a.manifest, b.manifest)
        XCTAssertEqual(a.manifestDigest, b.manifestDigest)
        XCTAssertEqual(a.manifest, c.manifest)
        XCTAssertEqual(a.entries.map(\.path), ["rime_ice.schema.yaml"])
        XCTAssertTrue(a.manifest.last == 0x0a)
        XCTAssertFalse(a.manifest.dropLast().contains(0x0a))
        XCTAssertTrue(a.manifestDigest.matches("^[0-9a-f]{64}$"))
        XCTAssertFalse(String(decoding: a.manifest, as: UTF8.self).contains(first.path))
    }

    func testIncludedChangesChangeDigestButTimestampDoesNot() throws {
        let root = try fixture(["rime_ice.schema.yaml": "a"])
        let initial = try digest(.schema, root: root)
        try "b".write(to: root.appendingPathComponent("rime_ice.schema.yaml"), atomically: true, encoding: .utf8)
        let byteChanged = try digest(.schema, root: root)
        XCTAssertNotEqual(initial.manifestDigest, byteChanged.manifestDigest)
        try "longer".write(to: root.appendingPathComponent("rime_ice.schema.yaml"), atomically: true, encoding: .utf8)
        let sizeChanged = try digest(.schema, root: root)
        XCTAssertNotEqual(byteChanged.manifestDigest, sizeChanged.manifestDigest)
        try FileManager.default.setAttributes(
            [.modificationDate: Date(timeIntervalSince1970: 1)],
            ofItemAtPath: root.appendingPathComponent("rime_ice.schema.yaml").path)
        XCTAssertEqual(sizeChanged.manifestDigest, try digest(.schema, root: root).manifestDigest)
    }

    func testMissingWrongSchemaUnsupportedAndForbiddenProvenanceFailClosed() throws {
        let empty = try fixture([:])
        try assertFailure(.missingRequiredInput) { try digest(.schema, root: empty) }
        let root = try fixture(["rime_ice.schema.yaml": "x", "other.yaml": "x"])
        try assertFailure(.unsupportedInput) { try digest(.schema, root: root) }
        try assertFailure(.wrongSchemaIdentity) { try digest(.schema, root: root, schema: "luna_pinyin") }
        try assertFailure(.forbiddenInput) { try digest(.schema, root: root, provenance: .sourceTree) }
    }

    func testSharedRuntimeClosedInventoryAndCanonicalOrdering() throws {
        let root = try fixture([
            "root.yaml": "1", "custom_phrase.txt": "2", "build/direct.bin": "3",
            "build/nested/config.yaml": "4", "cn_dicts/base.yaml": "5", "en_dicts/en.yaml": "6",
            "lua/filter.lua": "7", "opencc/map.json": "8", "opencc/nested/map.ocd2": "9",
        ])
        let result = try digest(.sharedRuntime, root: root, customPhraseApproved: true)
        XCTAssertEqual(
            result.entries.map(\.path), result.entries.map(\.path).sorted { $0.utf8.lexicographicallyPrecedes($1.utf8) }
        )
        XCTAssertEqual(result.entries.count, 9)
        try "x".write(to: root.appendingPathComponent("unknown.dat"), atomically: true, encoding: .utf8)
        try assertFailure(.unsupportedInput) { try digest(.sharedRuntime, root: root, customPhraseApproved: true) }
    }

    func testSharedRuntimeEmptyAndUnprovenCustomPhraseFailClosed() throws {
        try assertFailure(.missingRequiredInput) { try digest(.sharedRuntime, root: fixture([:])) }
        let root = try fixture(["custom_phrase.txt": "synthetic"])
        try assertFailure(.forbiddenInput) { try digest(.sharedRuntime, root: root) }
        XCTAssertNoThrow(try digest(.sharedRuntime, root: root, customPhraseApproved: true))
    }

    func testExclusionsAreReportedWithoutContentMetadata() throws {
        let root = try fixture([
            "root.yaml": "approved", "logs/private.log": "SECRET", "cache/item.yaml": "SECRET",
            "tmp/item.tmp": "SECRET", "state.lock": "SECRET", "old.backup": "SECRET",
            "diagnostics/run.trace": "SECRET", "dict.userdb/data": "SECRET", "sync/data.yaml": "SECRET",
            "user.yaml": "SECRET", "secrets/key.pem": "SECRET", "crash/report.ips": "SECRET",
        ])
        let result = try digest(.sharedRuntime, root: root)
        XCTAssertEqual(result.entries.map(\.path), ["root.yaml"])
        XCTAssertGreaterThanOrEqual(result.exclusions.count, 10)
        let output = String(decoding: result.manifest, as: UTF8.self)
        XCTAssertFalse(output.contains("SECRET"))
        XCTAssertFalse(result.exclusions.map(\.reason).joined().contains("SECRET"))
        XCTAssertTrue(result.exclusions.contains { $0.path == "logs/private.log" })
        XCTAssertTrue(result.exclusions.contains { $0.path == "dict.userdb/data" })
        XCTAssertTrue(result.exclusions.contains { $0.path == "diagnostics/run.trace" })
    }

    func testUnapprovedLookalikeIsNotSilentlyExcluded() throws {
        let root = try fixture(["root.yaml": "approved", "almost.userdbx": "unknown"])
        try assertFailure(.unsupportedInput) { try digest(.sharedRuntime, root: root) }
    }

    func testNestedExclusionDirectoriesAtAnyDepthAreExcludedBeforeRead() throws {
        let excludedPaths = [
            "nested/logs/private.yaml",
            "nested/cache/data.yaml",
            "one/two/three/tmp/incomplete.yaml",
            "one/two/backup/history.yaml",
            "one/two/crash/report.yaml",
            "one/two/telemetry/event.yaml",
            "one/two/diagnostics/report.yaml",
            "one/two/credentials/secret.yaml",
        ]
        var files = Dictionary(uniqueKeysWithValues: excludedPaths.map { ($0, "DO-NOT-READ") })
        files["root.yaml"] = "approved"
        let root = try fixture(files)
        let result = try EnvironmentDigester(readFile: { url in
            if excludedPaths.contains(String(url.path.dropFirst(root.path.count + 1))) {
                XCTFail("nested excluded content was read")
            }
            return try Data(contentsOf: url)
        }).digest(request(.sharedRuntime, root: root))

        XCTAssertEqual(result.entries.map(\.path), ["root.yaml"])
        for path in excludedPaths {
            XCTAssertTrue(result.exclusions.contains { $0.path == path }, "missing exclusion for \(path)")
        }
    }

    func testExplicitUserTextClassificationExcludesBeforeRead() throws {
        let root = try fixture(["root.yaml": "ok", "private.yaml": "SENTINEL"])
        let request = request(.sharedRuntime, root: root, prohibited: ["private.yaml"])
        let result = try EnvironmentDigester(readFile: { url in
            if url.lastPathComponent == "private.yaml" { XCTFail("prohibited content was read") }
            return try Data(contentsOf: url)
        }).digest(request)
        XCTAssertEqual(result.entries.map(\.path), ["root.yaml"])
        XCTAssertEqual(result.exclusions, [.init(path: "private.yaml", reason: "user-or-host-text")])
    }

    func testUserConfigurationExactAllowlistAndOpaqueBytes() throws {
        let root = try fixture([
            "default.custom.yaml": "patch: {}", "rime_ice.custom.yaml": "translator/enable_user_dict: true",
            "dict.userdb/data": "LEARNING", "sync/data": "LEARNING",
        ])
        let result = try digest(.userConfiguration, root: root)
        XCTAssertEqual(result.entries.map(\.path), ["default.custom.yaml", "rime_ice.custom.yaml"])
        XCTAssertFalse(String(decoding: result.manifest, as: UTF8.self).contains("enable_user_dict"))
        XCTAssertFalse(String(decoding: result.manifest, as: UTF8.self).contains("LEARNING"))
        try "x".write(to: root.appendingPathComponent("luna_pinyin.custom.yaml"), atomically: true, encoding: .utf8)
        try assertFailure(.unsupportedInput) { try digest(.userConfiguration, root: root) }
    }

    func testEffectiveConfigurationUsesExactBuildRootContract() throws {
        let root = try fixture(["rime_ice.schema.yaml": "compiled"])
        let result = try digest(.effectiveConfiguration, root: root)
        XCTAssertTrue(String(decoding: result.manifest, as: UTF8.self).contains("Rime/shared/build"))
        try "x".write(to: root.appendingPathComponent("extra.bin"), atomically: true, encoding: .utf8)
        try assertFailure(.unsupportedInput) { try digest(.effectiveConfiguration, root: root) }
    }

    func testSymlinkHardLinkMissingRootAndNonDirectoryFailClosed() throws {
        let target = try fixture(["rime_ice.schema.yaml": "x"])
        let symlinkRoot = newRootURL()
        try FileManager.default.createSymbolicLink(at: symlinkRoot, withDestinationURL: target)
        try assertFailure(.symlinkInput) { try digest(.schema, root: symlinkRoot) }
        let hardLinkRoot = try fixture(["rime_ice.schema.yaml": "x"])
        try FileManager.default.linkItem(
            at: hardLinkRoot.appendingPathComponent("rime_ice.schema.yaml"),
            to: hardLinkRoot.appendingPathComponent("alias.yaml"))
        try assertFailure(.nonRegularInput) { try digest(.schema, root: hardLinkRoot) }
        try assertFailure(.missingRoot) { try digest(.schema, root: newRootURL()) }
        let fileRoot = newRootURL()
        try Data("x".utf8).write(to: fileRoot)
        try assertFailure(.nonRegularInput) { try digest(.schema, root: fileRoot) }
    }

    func testUnreadableAndMutationDuringReadUseTypedAtomicFailures() throws {
        let root = try fixture(["rime_ice.schema.yaml": "before"])
        let unreadable = EnvironmentDigester(readFile: { _ in throw CocoaError(.fileReadNoPermission) })
        try assertFailure(.unreadableInput) { try unreadable.digest(request(.schema, root: root)) }
        let mutating = EnvironmentDigester(readFile: { url in
            let data = try Data(contentsOf: url)
            try Data("different-size".utf8).write(to: url)
            return data
        })
        try assertFailure(.inputChangedDuringRead) { try mutating.digest(request(.schema, root: root)) }
    }

    func testInventoryAdditionAndDeletionDuringReadFailClosed() throws {
        let additionRoot = try fixture(["root.yaml": "before"])
        let adding = EnvironmentDigester(readFile: { url in
            let data = try Data(contentsOf: url)
            try Data("added".utf8).write(to: additionRoot.appendingPathComponent("added.yaml"))
            return data
        })
        try assertFailure(.inputChangedDuringRead) {
            try adding.digest(request(.sharedRuntime, root: additionRoot))
        }

        let deletionRoot = try fixture(["root.yaml": "before", "logs/private.log": "excluded"])
        let deleting = EnvironmentDigester(readFile: { url in
            let data = try Data(contentsOf: url)
            try FileManager.default.removeItem(at: deletionRoot.appendingPathComponent("logs/private.log"))
            return data
        })
        try assertFailure(.inputChangedDuringRead) {
            try deleting.digest(request(.sharedRuntime, root: deletionRoot))
        }
    }

    func testCustomPhraseApprovalIsBoundIntoProvenanceEnvelope() throws {
        let root = try fixture(["custom_phrase.txt": "distribution"])
        let result = try digest(.sharedRuntime, root: root, customPhraseApproved: true)
        XCTAssertEqual(
            result.envelope.distributionArtifactApprovals,
            [
                .init(
                    path: "custom_phrase.txt", authority: "fixture-authority",
                    evidenceReference: "fixture-manifest#custom_phrase.txt", environmentIdentity: "fixture-a")
            ])

        let mismatched = FilesystemDigestRequest(
            profile: .sharedRuntime, root: root, environmentIdentity: "fixture-a",
            provenance: .controlledFixture, authorizedCaller: "EnvironmentDigestTests",
            sourceClassification: "verified_manifest", implementationCommit: commit,
            distributionCustomPhraseApproval: .init(
                path: "custom_phrase.txt", authority: "fixture-authority",
                evidenceReference: "fixture-manifest#custom_phrase.txt", environmentIdentity: "fixture-b"))
        try assertFailure(.mixedEnvironmentIdentity) { try EnvironmentDigester().digest(mismatched) }
    }

    func testInvocationDoesNotMutateInputRootOrWriteOutput() throws {
        let root = try fixture(["rime_ice.schema.yaml": "x"])
        let before = try treeSnapshot(root)
        _ = try digest(.schema, root: root)
        XCTAssertEqual(before, try treeSnapshot(root))
    }

    func testCleanStateCanonicalSuccessAndValidationFailures() throws {
        let facts = validFacts(identity: "run-a")
        let a = try EnvironmentDigester().digestCleanState(
            facts: facts.reversed(), authorizedCaller: "test", sourceClassification: "verified_manifest",
            implementationCommit: commit, evidenceClassification: .controlledFixture)
        let b = try EnvironmentDigester().digestCleanState(
            facts: facts, authorizedCaller: "test", sourceClassification: "verified_manifest",
            implementationCommit: commit, evidenceClassification: .controlledFixture)
        XCTAssertEqual(a.manifest, b.manifest)
        XCTAssertEqual(a.manifestDigest, b.manifestDigest)
        try assertFailure(.invalidCleanStateFact) {
            try EnvironmentDigester().digestCleanState(
                facts: Array(facts.dropLast()), authorizedCaller: "test", sourceClassification: "verified_manifest",
                implementationCommit: commit, evidenceClassification: .controlledFixture)
        }
        var invalidDigest = facts
        invalidDigest[invalidDigest.firstIndex(where: { $0.name == "schema_digest" })!] = .init(
            name: "schema_digest", value: .string("ABC"), source: "verified_manifest", environmentIdentity: "run-a")
        try assertFailure(.invalidCleanStateFact) {
            try EnvironmentDigester().digestCleanState(
                facts: invalidDigest, authorizedCaller: "test", sourceClassification: "verified_manifest",
                implementationCommit: commit, evidenceClassification: .controlledFixture)
        }
        var mixed = facts
        mixed[0] = .init(
            name: mixed[0].name, value: mixed[0].value, source: mixed[0].source, environmentIdentity: "run-b")
        try assertFailure(.mixedEnvironmentIdentity) {
            try EnvironmentDigester().digestCleanState(
                facts: mixed, authorizedCaller: "test", sourceClassification: "verified_manifest",
                implementationCommit: commit, evidenceClassification: .controlledFixture)
        }
        var wrongSource = facts
        wrongSource[0] = .init(
            name: wrongSource[0].name,
            value: wrongSource[0].value,
            source: "device_observed",
            environmentIdentity: "run-a"
        )
        try assertFailure(.invalidCleanStateFact) {
            try EnvironmentDigester().digestCleanState(
                facts: wrongSource,
                authorizedCaller: "test",
                sourceClassification: "verified_manifest",
                implementationCommit: commit,
                evidenceClassification: .controlledFixture
            )
        }
    }

    func testManifestContainsNoRawBytesAndEnvelopeSeparatesProvenance() throws {
        let root = try fixture(["rime_ice.schema.yaml": "RAW-SENTINEL"])
        let fixtureResult = try digest(.schema, root: root)
        XCTAssertFalse(String(decoding: fixtureResult.manifest, as: UTF8.self).contains("RAW-SENTINEL"))
        XCTAssertEqual(fixtureResult.envelope.evidenceClassification, "fixture-evidence-only")
        XCTAssertEqual(fixtureResult.envelope.toolVersion, "1.0.0")
        let deployed = try digest(.schema, root: root, provenance: .deployedRuntime)
        XCTAssertEqual(deployed.envelope.evidenceClassification, "caller-bound-deployed-input")
    }

    private func validFacts(identity: String) -> [CleanStateFact] {
        let digest = String(repeating: "a", count: 64)
        return [
            .init(
                name: "main_app_rebuilt", value: .bool(true), source: "capture_procedure", environmentIdentity: identity
            ),
            .init(
                name: "app_reinstalled", value: .bool(true), source: "device_observed", environmentIdentity: identity),
            .init(
                name: "extension_reinstalled", value: .bool(true), source: "device_observed",
                environmentIdentity: identity),
            .init(
                name: "deployment_recreated", value: .bool(true), source: "runtime_observed",
                environmentIdentity: identity),
            .init(
                name: "extension_process_restarted", value: .bool(true), source: "device_observed",
                environmentIdentity: identity),
            .init(
                name: "unfinished_composition", value: .string("absent"), source: "extension_runtime_observed",
                environmentIdentity: identity),
            .init(
                name: "typo_learning_state", value: .string("empty"), source: "verified_manifest",
                environmentIdentity: identity),
            .init(
                name: "rime_user_state", value: .string("clean-fixture"), source: "verified_manifest",
                environmentIdentity: identity),
            .init(
                name: "experiment_flags.insertion", value: .bool(false), source: "extension_runtime_observed",
                environmentIdentity: identity),
            .init(
                name: "experiment_flags.transposition", value: .bool(false), source: "extension_runtime_observed",
                environmentIdentity: identity),
            .init(
                name: "experiment_flags.typo_partial_commit", value: .bool(false), source: "extension_runtime_observed",
                environmentIdentity: identity),
            .init(
                name: "schema_digest", value: .string(digest), source: "verified_manifest",
                environmentIdentity: identity),
            .init(
                name: "shared_runtime_digest", value: .string(digest), source: "verified_manifest",
                environmentIdentity: identity),
            .init(
                name: "user_configuration_digest", value: .string(digest), source: "verified_manifest",
                environmentIdentity: identity),
            .init(
                name: "effective_configuration_digest", value: .string(digest), source: "verified_manifest",
                environmentIdentity: identity),
        ]
    }

    private func digest(
        _ profile: DigestProfile, root: URL, schema: String = "rime_ice",
        provenance: RootProvenance = .controlledFixture, customPhraseApproved: Bool = false
    ) throws -> DigestResult {
        try EnvironmentDigester().digest(
            request(
                profile, root: root, schema: schema, provenance: provenance, customPhraseApproved: customPhraseApproved)
        )
    }

    private func request(
        _ profile: DigestProfile, root: URL, schema: String = "rime_ice",
        provenance: RootProvenance = .controlledFixture, customPhraseApproved: Bool = false,
        prohibited: Set<String> = []
    ) -> FilesystemDigestRequest {
        let approval: DistributionArtifactApproval? =
            customPhraseApproved
            ? .init(
                path: "custom_phrase.txt", authority: "fixture-authority",
                evidenceReference: "fixture-manifest#custom_phrase.txt", environmentIdentity: "fixture-a")
            : nil
        return .init(
            profile: profile, root: root, schemaIdentity: schema, environmentIdentity: "fixture-a",
            provenance: provenance, authorizedCaller: "EnvironmentDigestTests",
            sourceClassification: "verified_manifest", implementationCommit: commit,
            distributionCustomPhraseApproval: approval, explicitlyProhibitedPaths: prohibited)
    }

    private func fixture(_ files: [String: String]) throws -> URL {
        let root = newRootURL()
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        for (path, content) in files {
            let url = root.appendingPathComponent(path)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(content.utf8).write(to: url)
        }
        return root
    }

    private func newRootURL() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            "environment-digest-tests-\(UUID().uuidString)")
        roots.append(url)
        return url
    }

    private func treeSnapshot(_ root: URL) throws -> [String: Data] {
        let items = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)!
        var snapshot: [String: Data] = [:]
        while let url = items.nextObject() as? URL {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue {
                snapshot[String(url.path.dropFirst(root.path.count + 1))] = try Data(contentsOf: url)
            }
        }
        return snapshot
    }

    private func assertFailure<T>(_ code: DigestFailureCode, _ operation: () throws -> T) throws {
        XCTAssertThrowsError(try operation()) { error in XCTAssertEqual((error as? DigestFailure)?.code, code) }
    }

    private var commit: String { String(repeating: "a", count: 40) }
}

private extension String {
    func matches(_ pattern: String) -> Bool { range(of: pattern, options: .regularExpression) != nil }
}
