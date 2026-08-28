import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

@MainActor
final class SchemaArtifactSecurityTests: XCTestCase {
    func testArchiveVerificationBindsExactSizeAndSHA256() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let archiveURL = root.appendingPathComponent("artifact.zip")
        try Data("hello".utf8).write(to: archiveURL)
        let validSource = makeSource(
            expectedByteCount: 5,
            archiveSHA256: "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        )

        XCTAssertEqual(
            try SchemaArtifactVerifier().verifyArchive(at: archiveURL, source: validSource),
            validSource.archiveSHA256
        )
        XCTAssertThrowsError(
            try SchemaArtifactVerifier().verifyArchive(
                at: archiveURL,
                source: makeSource(expectedByteCount: 4, archiveSHA256: validSource.archiveSHA256)
            )
        ) {
            XCTAssertEqual(
                $0 as? DownloadError,
                .integrityMismatch(.archiveSize(expected: 4, actual: 5))
            )
        }
        XCTAssertThrowsError(
            try SchemaArtifactVerifier().verifyArchive(
                at: archiveURL,
                source: makeSource(expectedByteCount: 5, archiveSHA256: String(repeating: "0", count: 64))
            )
        ) {
            XCTAssertEqual(
                $0 as? DownloadError,
                .integrityMismatch(
                    .archiveDigest(
                        expected: String(repeating: "0", count: 64),
                        actual: validSource.archiveSHA256
                    )
                )
            )
        }
    }

    func testStagedDigestIgnoresUnadmittedPurePayloadButBindsInstalledFiles() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let plan = makePlan()
        try write("schema-v1", to: root.appendingPathComponent("wanxiang.schema.yaml"))
        try write("dictionary-v1", to: root.appendingPathComponent("dicts/base.dict.yaml"))
        let pureFiles = [
            "custom/wanxiang_pure.schema.yaml",
            "custom/wanxiang_pure.dict.yaml",
            "custom/wanxiang_pure.custom.yaml",
        ]
        for file in pureFiles {
            try write("pure-a", to: root.appendingPathComponent(file))
        }

        let verifier = SchemaArtifactVerifier()
        let baseline = try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: true)
        for file in pureFiles {
            try write("pure-b", to: root.appendingPathComponent(file))
        }
        let excludedChange = try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: true)
        XCTAssertEqual(baseline, excludedChange)

        try write("dictionary-v2", to: root.appendingPathComponent("dicts/base.dict.yaml"))
        let installedChange = try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: true)
        XCTAssertNotEqual(baseline, installedChange)
    }

    func testStagedDigestSeparatesLuaAndNonLuaInstallProfiles() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let plan = makePlan()
        try write("schema", to: root.appendingPathComponent("wanxiang.schema.yaml"))
        try write("dictionary", to: root.appendingPathComponent("dicts/base.dict.yaml"))
        try write("lua-v1", to: root.appendingPathComponent("lua/date.lua"))

        let verifier = SchemaArtifactVerifier()
        let withLua = try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: true)
        let withoutLua = try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: false)
        XCTAssertNotEqual(withLua, withoutLua)

        try write("lua-v2", to: root.appendingPathComponent("lua/date.lua"))
        XCTAssertEqual(
            withoutLua,
            try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: false)
        )
    }

    func testLocalizedNetworkErrorsDoNotExposeRawSystemText() {
        XCTAssertEqual(
            DownloadError.userFacingDescription(for: URLError(.notConnectedToInternet)),
            "网络连接不可用，请检查蜂窝网络或 Wi-Fi 后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(for: URLError(.timedOut)),
            "下载源响应超时，已尝试切换其他来源，请稍后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(for: URLError(.cannotFindHost)),
            "暂时无法连接下载源，请稍后重试"
        )
    }

    func testManifestResolvesAllSourcesToOneExplicitStagedIdentity() throws {
        for entry in RimeSchemeCatalog.downloadableEntries {
            let manifest = try XCTUnwrap(entry.distribution?.manifest)
            let identities = try manifest.sourceVariants.map {
                try manifest.resolvedStagedIdentity(for: $0)
            }
            XCTAssertFalse(identities.isEmpty)
            XCTAssertTrue(identities.allSatisfy { $0 == identities[0] })
        }
    }

    func testManifestRejectsUnresolvedStagedIdentity() throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let source = try XCTUnwrap(manifest.sourceVariants.first)
        let unresolved = RimeSchemeSourceVariant(
            id: source.id,
            displayName: source.displayName,
            downloadURL: source.downloadURL,
            upstreamRevision: source.upstreamRevision,
            expectedByteCount: source.expectedByteCount,
            archiveSHA256: source.archiveSHA256,
            allowedRedirectHosts: source.allowedRedirectHosts,
            stagedIdentityID: "missing"
        )

        XCTAssertThrowsError(try manifest.resolvedStagedIdentity(for: unresolved)) {
            XCTAssertEqual($0 as? DownloadError, .invalidArtifactManifest)
        }
    }

    func testManifestRejectsMalformedDigestAndStaleImplementationRevision() throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let source = try XCTUnwrap(manifest.sourceVariants.first)
        let malformed = RimeSchemeSourceVariant(
            id: source.id,
            displayName: source.displayName,
            downloadURL: source.downloadURL,
            upstreamRevision: source.upstreamRevision,
            expectedByteCount: source.expectedByteCount,
            archiveSHA256: "not-a-sha256",
            allowedRedirectHosts: source.allowedRedirectHosts,
            stagedIdentityID: source.stagedIdentityID
        )
        let malformedManifest = RimeSchemeArtifactManifest(
            schemeID: manifest.schemeID,
            version: manifest.version,
            assetName: manifest.assetName,
            sourceVariants: [malformed],
            stagedIdentities: manifest.stagedIdentities
        )
        XCTAssertThrowsError(try malformedManifest.resolvedStagedIdentity(for: malformed)) {
            XCTAssertEqual($0 as? DownloadError, .invalidArtifactManifest)
        }

        let identity = try manifest.resolvedStagedIdentity(for: source)
        XCTAssertThrowsError(
            try manifest.validateImplementationBinding(
                identity,
                installationPlan: makePlan(),
                postProcessingRevision: "stale-post-revision"
            )
        ) {
            XCTAssertEqual($0 as? DownloadError, .invalidArtifactManifest)
        }
    }

    func testStagedMismatchNeverPermitsSourceFallback() {
        XCTAssertFalse(
            DownloadIntegrityFailure.stagedContent(
                expected: String(repeating: "0", count: 64),
                actual: String(repeating: "1", count: 64)
            ).permitsPinnedSourceFallback
        )
    }

    func testCleanupReceiptBindsExactRegisteredArtifactAndVerifiesAbsence() async throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("failed.zip")
        try Data("failed".utf8).write(to: url)
        let artifact = SchemaOwnedTemporaryArtifact(
            operationID: UUID(),
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: url
        )
        let registry = SchemaTemporaryArtifactRegistry()
        try await registry.register(artifact)

        let receipt = try await FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
            .removeAndVerifyAbsent(artifact)

        XCTAssertTrue(receipt.provesRemoval(of: artifact))
        XCTAssertEqual(receipt.outcome, .removed)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        let stale = SchemaOwnedTemporaryArtifact(
            operationID: artifact.operationID,
            attemptID: UUID(),
            sourceID: artifact.sourceID,
            artifactID: artifact.artifactID,
            localURL: artifact.localURL
        )
        XCTAssertFalse(receipt.provesRemoval(of: stale))
    }

    func testCleanupRejectsUnregisteredAlreadyAbsentArtifact() async throws {
        let artifact = SchemaOwnedTemporaryArtifact(
            operationID: UUID(),
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("unregistered-\(UUID().uuidString).zip")
        )

        do {
            _ = try await FileSystemSchemaTemporaryArtifactCleaner(
                registry: SchemaTemporaryArtifactRegistry()
            ).removeAndVerifyAbsent(artifact)
            XCTFail("unregistered artifact must be rejected")
        } catch {
            XCTAssertEqual(error as? DownloadError, .temporaryCleanupFailed)
        }
    }

    func testCleanupAcceptsRegisteredAlreadyAbsentArtifact() async throws {
        let registry = SchemaTemporaryArtifactRegistry()
        let artifact = SchemaOwnedTemporaryArtifact(
            operationID: UUID(),
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("registered-absent-\(UUID().uuidString).zip")
        )
        try await registry.register(artifact)

        let receipt = try await FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
            .removeAndVerifyAbsent(artifact)

        XCTAssertTrue(receipt.provesRemoval(of: artifact))
        XCTAssertEqual(receipt.outcome, .alreadyAbsent)
    }

    func testCleanupFailsClosedWhenDeletionFails() async throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("undeletable.zip")
        try Data("failed".utf8).write(to: url)
        let registry = SchemaTemporaryArtifactRegistry()
        let artifact = SchemaOwnedTemporaryArtifact(
            operationID: UUID(),
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: url
        )
        try await registry.register(artifact)
        let cleaner = FileSystemSchemaTemporaryArtifactCleaner(
            registry: registry,
            removeItem: { _ in throw CocoaError(.fileWriteNoPermission) }
        )

        do {
            _ = try await cleaner.removeAndVerifyAbsent(artifact)
            XCTFail("deletion failure must fail closed")
        } catch {
            XCTAssertEqual(error as? DownloadError, .temporaryCleanupFailed)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testStaleCleanupReceiptDoesNotProveALaterAttempt() async throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let firstURL = root.appendingPathComponent("first.zip")
        let secondURL = root.appendingPathComponent("second.zip")
        try Data("first".utf8).write(to: firstURL)
        try Data("second".utf8).write(to: secondURL)
        let operationID = UUID()
        let first = SchemaOwnedTemporaryArtifact(
            operationID: operationID,
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: firstURL
        )
        let second = SchemaOwnedTemporaryArtifact(
            operationID: operationID,
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: secondURL
        )
        let registry = SchemaTemporaryArtifactRegistry()
        try await registry.register(first)
        try await registry.register(second)
        let receipt = try await FileSystemSchemaTemporaryArtifactCleaner(registry: registry)
            .removeAndVerifyAbsent(first)

        XCTAssertTrue(receipt.provesRemoval(of: first))
        XCTAssertFalse(receipt.provesRemoval(of: second))
    }

    func testDownloaderRemovesUnregisteredFileOnNonHTTPResponse() async throws {
        let url = try makeTemporaryArchive()
        defer { try? FileManager.default.removeItem(at: url) }
        let source = makeSource(id: "cnb")
        let downloader = URLSessionSchemaArchiveDownloader(
            registry: SchemaTemporaryArtifactRegistry()
        )

        do {
            _ = try await downloader.adoptDownloadedFile(
                temporaryURL: url,
                response: URLResponse(
                    url: source.downloadURL,
                    mimeType: "application/zip",
                    expectedContentLength: 6,
                    textEncodingName: nil
                ),
                source: source,
                operationID: UUID(),
                attemptID: UUID()
            )
            XCTFail("non-HTTP responses must be rejected")
        } catch {
            XCTAssertEqual(error as? DownloadError, .networkError("无效的 HTTP 响应"))
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testDownloaderRemovesUnregisteredFileOnDisallowedHostAndZeroLength() async throws {
        let hostURL = try makeTemporaryArchive()
        let lengthURL = try makeTemporaryArchive()
        defer {
            try? FileManager.default.removeItem(at: hostURL)
            try? FileManager.default.removeItem(at: lengthURL)
        }
        let source = makeSource(id: "cnb")
        let downloader = URLSessionSchemaArchiveDownloader(
            registry: SchemaTemporaryArtifactRegistry()
        )

        do {
            _ = try await downloader.adoptDownloadedFile(
                temporaryURL: hostURL,
                response: try XCTUnwrap(
                    HTTPURLResponse(
                        url: URL(string: "https://evil.example.test/artifact.zip")!,
                        statusCode: 200,
                        httpVersion: "HTTP/1.1",
                        headerFields: ["Content-Length": "6"]
                    )
                ),
                source: source,
                operationID: UUID(),
                attemptID: UUID()
            )
            XCTFail("disallowed host must be rejected")
        } catch {
            XCTAssertEqual(error as? DownloadError, .networkError("下载失败，HTTP 200"))
        }

        do {
            _ = try await downloader.adoptDownloadedFile(
                temporaryURL: lengthURL,
                response: try XCTUnwrap(
                    HTTPURLResponse(
                        url: source.downloadURL,
                        statusCode: 200,
                        httpVersion: "HTTP/1.1",
                        headerFields: ["Content-Length": "0"]
                    )
                ),
                source: source,
                operationID: UUID(),
                attemptID: UUID()
            )
            XCTFail("zero-length responses must be rejected")
        } catch {
            XCTAssertEqual(error as? DownloadError, .networkError("服务器未提供文件大小"))
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: hostURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: lengthURL.path))
    }

    func testLocalizedIntegrityErrorsDoNotExposeRawDigests() {
        XCTAssertEqual(
            DownloadError.userFacingDescription(
                for: DownloadError.integrityMismatch(
                    .archiveSize(expected: 10, actual: 4)
                )
            ),
            "下载文件不完整，已停止安装，请检查网络后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(
                for: DownloadError.integrityMismatch(
                    .archiveDigest(
                        expected: String(repeating: "a", count: 64),
                        actual: String(repeating: "b", count: 64)
                    )
                )
            ),
            "下载文件未通过安全校验，已停止安装，请稍后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(
                for: DownloadError.integrityMismatch(
                    .stagedContent(
                        expected: String(repeating: "a", count: 64),
                        actual: String(repeating: "b", count: 64)
                    )
                )
            ),
            "方案内容未通过安装前校验，已停止安装，请稍后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(
                for: DownloadError.allSourcesFailedIntegrity(.archiveDigest)
            ),
            "所有下载源均未通过安全校验，已停止安装，请稍后重试"
        )
        XCTAssertEqual(
            DownloadError.userFacingDescription(
                for: DownloadError.allSourcesFailedIntegrity(.mixed)
            ),
            "所有下载源均未通过完整性校验，已停止安装，请稍后重试"
        )
    }

    func testSchemeDeliveryFormatterUsesReviewedEnumsWithoutPaths() {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 0),
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryIntegrityFailed,
            level: .warning,
            category: .deployment,
            schemeDeliveryPayload: .integrityFailed(
                .init(
                    context: context,
                    attempt: DiagnosticEvent.SchemeDeliveryAttempt(1)!,
                    source: .cnb,
                    host: .cnbAsset,
                    observation: .archiveDigest(
                        expected: DiagnosticEvent.DigestPrefix16(rawValue: "0123456789abcdef")!,
                        actual: DiagnosticEvent.DigestPrefix16(rawValue: "fedcba9876543210")!
                    )
                )
            )
        )
        let line = DiagnosticsEventDisplayFormatter.line(event)
        XCTAssertTrue(line.contains("artifact=wanxiang_17_5_9_cnb9bfc_github73f8"))
        XCTAssertTrue(line.contains("source=cnb"))
        XCTAssertTrue(line.contains("host=asset.cnb.cool"))
        XCTAssertTrue(line.contains("integrity=archive_digest"))
        XCTAssertFalse(line.contains("/var"))
        XCTAssertFalse(line.contains("https://"))
        XCTAssertTrue(line.contains("scheme_delivery.integrity_failed"))
        XCTAssertTrue(line.contains("wanxiang"))
    }

    func testSchemeDeliveryPhaseLinesAreSearchableWithoutChineseFreeText() {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        func line(phase: DiagnosticEvent.SchemeDeliveryPhase) -> String {
            DiagnosticsEventDisplayFormatter.line(
                DiagnosticEvent(
                    utcTimestamp: Date(timeIntervalSince1970: 0),
                    monotonicNanoseconds: 1,
                    origin: .mainApp,
                    processInstanceID: UUID(),
                    localSequence: 1,
                    code: .schemeDeliveryPhaseChanged,
                    level: .info,
                    category: .deployment,
                    schemeDeliveryPayload: .phaseChanged(
                        .init(
                            context: context,
                            attempt: DiagnosticEvent.SchemeDeliveryAttempt(1)!,
                            source: .github,
                            host: .github,
                            phase: phase,
                            result: .started
                        )
                    )
                )
            )
        }

        let downloading = line(phase: .downloading)
        let deploying = line(phase: .deploying)
        XCTAssertTrue(downloading.contains("scheme_delivery.phase_changed"))
        XCTAssertTrue(downloading.contains("phase=downloading"))
        XCTAssertTrue(downloading.contains("wanxiang"))
        XCTAssertTrue(deploying.contains("phase=deploying"))
        XCTAssertFalse(downloading.contains("万象"))
        XCTAssertFalse(deploying.contains("/tmp"))
    }

    func testCleanupFailsClosedWhenExistenceCheckFails() async throws {
        let registry = SchemaTemporaryArtifactRegistry()
        let artifact = SchemaOwnedTemporaryArtifact(
            operationID: UUID(),
            attemptID: UUID(),
            sourceID: "cnb",
            artifactID: UUID(),
            localURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("existence-failure-\(UUID().uuidString).zip")
        )
        try await registry.register(artifact)
        let cleaner = FileSystemSchemaTemporaryArtifactCleaner(
            registry: registry,
            removeItem: { _ in },
            itemExists: { _ in throw CocoaError(.fileReadUnknown) }
        )

        do {
            _ = try await cleaner.removeAndVerifyAbsent(artifact)
            XCTFail("existence-check failure must fail closed")
        } catch {
            XCTAssertEqual(error as? DownloadError, .temporaryCleanupFailed)
        }
    }

    func testSourceSelectionHedgesAndCancelsSlowerPreferredProbe() async throws {
        let preferred = makeSource(id: "preferred")
        let fallback = makeSource(id: "fallback")
        let probe = ControlledSourceProbe(
            delays: ["preferred": 500_000_000, "fallback": 5_000_000],
            reachableIDs: ["preferred", "fallback"]
        )
        let selector = URLSessionSchemaSourceSelector(
            probe: probe,
            hedgeDelayNanoseconds: 1_000_000
        )

        let selected = try await selector.selectSource(
            from: [preferred, fallback],
            preferredSourceID: preferred.id
        )

        XCTAssertEqual(selected.id, fallback.id)
        let cancelledIDs = await probe.cancelledIDs()
        XCTAssertTrue(cancelledIDs.contains(preferred.id))
    }

    func testSourceSelectionNeverProbesMoreThanTwoVariants() async throws {
        let first = makeSource(id: "first")
        let second = makeSource(id: "second")
        let third = makeSource(id: "third")
        let probe = ControlledSourceProbe(
            delays: ["first": 500_000_000, "second": 5_000_000, "third": 1],
            reachableIDs: ["first", "second", "third"]
        )
        let selector = URLSessionSchemaSourceSelector(
            probe: probe,
            hedgeDelayNanoseconds: 1_000_000
        )

        let selected = try await selector.selectSource(
            from: [first, second, third],
            preferredSourceID: first.id
        )

        XCTAssertEqual(selected.id, second.id)
        let probedIDs = await probe.probedIDs()
        XCTAssertEqual(probedIDs, ["first", "second"])
    }

    private func makeTemporaryArchive() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-dl-reject-\(UUID().uuidString).zip")
        try Data("failed".utf8).write(to: url)
        return url
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("schema-artifact-security-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func write(_ content: String, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(content.utf8).write(to: url)
    }

    private func makeSource(
        id: String = "source",
        expectedByteCount: Int64 = 1,
        archiveSHA256: String = String(repeating: "0", count: 64)
    ) -> RimeSchemeSourceVariant {
        RimeSchemeSourceVariant(
            id: id,
            displayName: id,
            downloadURL: URL(string: "https://\(id).example.test/artifact.zip")!,
            upstreamRevision: "revision",
            expectedByteCount: expectedByteCount,
            archiveSHA256: archiveSHA256,
            allowedRedirectHosts: ["\(id).example.test"],
            stagedIdentityID: "test-identity"
        )
    }

    private func makePlan() -> RimeSchemeInstallationPlan {
        RimeSchemeInstallationPlan(
            revision: "test-plan-1",
            schemaFileName: "wanxiang.schema.yaml",
            luaDirectoryPrefix: "lua/",
            allowedFiles: ["wanxiang.schema.yaml"],
            allowedPrefixes: ["dicts/", "lua/"],
            skippedPrefixes: [],
            skippedFiles: [],
            removableFiles: [],
            removableDirectories: [],
            removableBuildFileSubstrings: []
        )
    }
}

private actor ControlledSourceProbe: SchemaSourceProbing {
    private let delays: [String: UInt64]
    private let reachableIDs: Set<String>
    private var cancellations = Set<String>()
    private var probes = Set<String>()

    init(delays: [String: UInt64], reachableIDs: Set<String>) {
        self.delays = delays
        self.reachableIDs = reachableIDs
    }

    func isReachable(_ variant: RimeSchemeSourceVariant) async throws -> Bool {
        probes.insert(variant.id)
        do {
            try await Task.sleep(nanoseconds: delays[variant.id] ?? 0)
            return reachableIDs.contains(variant.id)
        } catch is CancellationError {
            cancellations.insert(variant.id)
            throw CancellationError()
        }
    }

    func cancelledIDs() -> Set<String> {
        cancellations
    }

    func probedIDs() -> Set<String> {
        probes
    }
}
