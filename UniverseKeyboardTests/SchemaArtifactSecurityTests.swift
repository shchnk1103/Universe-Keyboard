import Foundation
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
        ) { XCTAssertEqual($0 as? DownloadError, .integrityMismatch) }
        XCTAssertThrowsError(
            try SchemaArtifactVerifier().verifyArchive(
                at: archiveURL,
                source: makeSource(expectedByteCount: 5, archiveSHA256: String(repeating: "0", count: 64))
            )
        ) { XCTAssertEqual($0 as? DownloadError, .integrityMismatch) }
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
            allowedRedirectHosts: ["\(id).example.test"]
        )
    }

    private func makePlan() -> RimeSchemeInstallationPlan {
        RimeSchemeInstallationPlan(
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
