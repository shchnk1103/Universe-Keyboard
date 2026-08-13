import CryptoKit
import Foundation
import RimeBridgeObjC
import XCTest

/// Test-only bridge for the TD-012 G2 physical-device spike.
///
/// `devicectl` can transfer bytes only into the App Group's allowed `tmp`
/// subtree, while RIME resolves shared resources from the root-level
/// `Rime/shared` directory. These tests perform that final same-container move
/// only when an exact, pre-pinned file (or cleanup request) is present.
/// Normal CI and ordinary device test runs skip both methods.
final class TD012LMDGDeviceStagingTests: XCTestCase {
    private struct ModelIdentity: Equatable {
        let byteCount: Int
        let sha256: String
    }

    private enum StagingError: Error, Equatable {
        case notRegularFile
        case byteCountMismatch(expected: Int, actual: Int?)
        case sha256Mismatch(expected: String, actual: String)
        case destinationAlreadyExists
        case partialDestinationAlreadyExists
    }

    private enum Fixture {
        static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
        static let modelName = "wanxiang-lts-zh-hans.gram"
        static let expectedByteCount = 420_251_692
        static let expectedSHA256 = "90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66"

        static let stagingRelativePath = "tmp/td012-g2/\(modelName)"
        // CoreDevice 642 may treat a trailing-slash destination as the final
        // file name. Keep that isolated form recoverable under the same pin.
        static let flatStagingRelativePath = "tmp/td012-g2"
        static let cleanupRequestRelativePath = "tmp/td012-g2/cleanup.request"
        static let installedRelativePath = "Rime/shared/\(modelName)"
        static let partialInstallSuffix = ".td012-staging"

        static let modelIdentity = ModelIdentity(
            byteCount: expectedByteCount,
            sha256: expectedSHA256
        )
    }

    func testStagePinnedModelForAuthorizedPhysicalDeviceSpike() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("TD-012 G2 staging is physical-device-only")
        #else
            let container = try appGroupContainer()
            let preferredSource = container.appendingPathComponent(Fixture.stagingRelativePath)
            let flatSource = container.appendingPathComponent(Fixture.flatStagingRelativePath)
            let source =
                FileManager.default.fileExists(atPath: preferredSource.path)
                ? preferredSource
                : flatSource
            guard FileManager.default.fileExists(atPath: source.path) else {
                throw XCTSkip(
                    "No explicitly transferred TD-012 G2 model fixture in container "
                        + container.lastPathComponent
                )
            }

            let destination = container.appendingPathComponent(Fixture.installedRelativePath)
            try stagePinnedModel(
                from: source,
                to: destination,
                identity: Fixture.modelIdentity
            )
        #endif
    }

    func testRemovePinnedModelAfterAuthorizedPhysicalDeviceSpike() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("TD-012 G2 cleanup is physical-device-only")
        #else
            let container = try appGroupContainer()
            let cleanupRequest = container.appendingPathComponent(Fixture.cleanupRequestRelativePath)
            guard FileManager.default.fileExists(atPath: cleanupRequest.path) else {
                throw XCTSkip("No explicit TD-012 G2 cleanup request")
            }

            let destination = container.appendingPathComponent(Fixture.installedRelativePath)
            try removePinnedModel(
                at: destination,
                cleanupRequest: cleanupRequest,
                identity: Fixture.modelIdentity
            )
        #endif
    }

    func testPinnedModelLoadsThroughWanxiangGrammarOnAuthorizedPhysicalDevice() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("TD-012 G2 model-load receipt is physical-device-only")
        #else
            let container = try appGroupContainer()
            let model = container.appendingPathComponent(Fixture.installedRelativePath)
            guard FileManager.default.fileExists(atPath: model.path) else {
                throw XCTSkip("No staged TD-012 G2 model fixture")
            }
            try requirePinnedModel(at: model, identity: Fixture.modelIdentity)

            let shared = container.appendingPathComponent("Rime/shared", isDirectory: true)
            let user = container.appendingPathComponent("Rime/user", isDirectory: true)
            let manager = RimeSessionManager()
            defer { manager.finalize() }
            guard manager.setup(withSharedDataDir: shared.path, userDataDir: user.path) else {
                XCTFail("RIME setup failed before the model-load probe")
                return
            }
            guard manager.initializeEngine() else {
                XCTFail("RIME initialization failed before the model-load probe")
                return
            }
            // Arm only after setup/initialize have succeeded, immediately
            // before the single probe. Reading the receipt below disarms it.
            RimeDeployer.resetGrammarModelLoadReceipt(forModelFileName: Fixture.modelName)
            XCTAssertTrue(
                RimeDeployer.probeGrammarModelLoad(forLanguage: "wanxiang-lts-zh-hans")
            )

            let receipt = RimeDeployer.grammarModelLoadReceipt()
            XCTAssertEqual(receipt["loadStarted"]?.boolValue, true)
            XCTAssertEqual(receipt["validDoubleArrayObserved"]?.boolValue, true)
            XCTAssertEqual(receipt["doubleArraySize"]?.uint64Value, 105_062_912)
        #endif
    }

    func testStageRejectsHashMismatchWithoutMovingSource() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("expected".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let wrongIdentity = ModelIdentity(
            byteCount: fixture.identity.byteCount,
            sha256: String(repeating: "0", count: 64)
        )

        XCTAssertThrowsError(
            try stagePinnedModel(from: fixture.source, to: fixture.destination, identity: wrongIdentity)
        ) { error in
            XCTAssertEqual(
                error as? StagingError,
                .sha256Mismatch(expected: wrongIdentity.sha256, actual: fixture.identity.sha256)
            )
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixture.source.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.destination.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.partialDestination.path))
    }

    func testStageRejectsByteCountMismatchWithoutMovingSource() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("expected".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let wrongIdentity = ModelIdentity(
            byteCount: fixture.identity.byteCount + 1,
            sha256: fixture.identity.sha256
        )

        XCTAssertThrowsError(
            try stagePinnedModel(from: fixture.source, to: fixture.destination, identity: wrongIdentity)
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixture.source.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.destination.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.partialDestination.path))
    }

    func testStageRejectsDirectoryWithoutMovingIt() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("unused".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        try FileManager.default.removeItem(at: fixture.source)
        try FileManager.default.createDirectory(at: fixture.source, withIntermediateDirectories: false)

        XCTAssertThrowsError(
            try stagePinnedModel(from: fixture.source, to: fixture.destination, identity: fixture.identity)
        ) { error in
            XCTAssertEqual(error as? StagingError, .notRegularFile)
        }
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixture.source.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.destination.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.partialDestination.path))
    }

    func testStageRejectsExistingDestinationWithoutMovingSource() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("expected".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let existingData = Data("existing".utf8)
        try existingData.write(to: fixture.destination)

        XCTAssertThrowsError(
            try stagePinnedModel(
                from: fixture.source,
                to: fixture.destination,
                identity: fixture.identity
            )
        ) { error in
            XCTAssertEqual(error as? StagingError, .destinationAlreadyExists)
        }
        XCTAssertEqual(try Data(contentsOf: fixture.source), Data("expected".utf8))
        XCTAssertEqual(try Data(contentsOf: fixture.destination), existingData)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.partialDestination.path))
    }

    func testStageRejectsExistingPartialWithoutMovingSource() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("expected".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let residue = Data("residue".utf8)
        try residue.write(to: fixture.partialDestination)

        XCTAssertThrowsError(
            try stagePinnedModel(
                from: fixture.source,
                to: fixture.destination,
                identity: fixture.identity
            )
        ) { error in
            XCTAssertEqual(error as? StagingError, .partialDestinationAlreadyExists)
        }
        XCTAssertEqual(try Data(contentsOf: fixture.source), Data("expected".utf8))
        XCTAssertEqual(try Data(contentsOf: fixture.partialDestination), residue)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.destination.path))
    }

    func testCleanupRejectsHashMismatchWithoutDeletingModelOrRequest() throws {
        let fixture = try makeTemporaryFixture(sourceData: Data("unused".utf8))
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let installedData = Data("installed".utf8)
        try installedData.write(to: fixture.destination)
        let cleanupRequest = fixture.root.appendingPathComponent("cleanup.request")
        try Data().write(to: cleanupRequest)
        let wrongIdentity = ModelIdentity(
            byteCount: installedData.count,
            sha256: String(repeating: "0", count: 64)
        )

        XCTAssertThrowsError(
            try removePinnedModel(
                at: fixture.destination,
                cleanupRequest: cleanupRequest,
                identity: wrongIdentity
            )
        )
        XCTAssertEqual(try Data(contentsOf: fixture.destination), installedData)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cleanupRequest.path))
    }

    func testStageAndCleanupSucceedForExactlyPinnedModel() throws {
        let modelData = Data("expected".utf8)
        let fixture = try makeTemporaryFixture(sourceData: modelData)
        defer { try? FileManager.default.removeItem(at: fixture.root) }
        let cleanupRequest = fixture.root.appendingPathComponent("cleanup.request")
        try Data().write(to: cleanupRequest)

        try stagePinnedModel(
            from: fixture.source,
            to: fixture.destination,
            identity: fixture.identity
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.source.path))
        XCTAssertEqual(try Data(contentsOf: fixture.destination), modelData)

        try removePinnedModel(
            at: fixture.destination,
            cleanupRequest: cleanupRequest,
            identity: fixture.identity
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: fixture.destination.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: cleanupRequest.path))
    }

    private func appGroupContainer() throws -> URL {
        guard
            let container = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: Fixture.appGroupID
            )
        else {
            XCTFail("Universe Keyboard App Group is unavailable")
            throw CocoaError(.fileNoSuchFile)
        }
        return container
    }

    private func stagePinnedModel(from source: URL, to destination: URL, identity: ModelIdentity) throws {
        try requirePinnedModel(at: source, identity: identity)
        guard !FileManager.default.fileExists(atPath: destination.path) else {
            throw StagingError.destinationAlreadyExists
        }
        let partialDestination = destination.appendingPathExtension(Fixture.partialInstallSuffix)
        guard !FileManager.default.fileExists(atPath: partialDestination.path) else {
            throw StagingError.partialDestinationAlreadyExists
        }

        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // 先移入 RIME 不会解析的临时名称并再次校验。最终同容器 rename 保留
        // 已校验 inode 的字节；因此无效字节永远不会以正式模型名称暴露。
        try FileManager.default.moveItem(at: source, to: partialDestination)
        do {
            try requirePinnedModel(at: partialDestination, identity: identity)
        } catch {
            // Rollback failure can leave only the non-resolvable partial name,
            // never the production `.gram` destination.
            try FileManager.default.moveItem(at: partialDestination, to: source)
            throw error
        }
        try FileManager.default.moveItem(at: partialDestination, to: destination)
    }

    private func removePinnedModel(
        at destination: URL,
        cleanupRequest: URL,
        identity: ModelIdentity
    ) throws {
        try requirePinnedModel(at: destination, identity: identity)
        try FileManager.default.removeItem(at: destination)
        try FileManager.default.removeItem(at: cleanupRequest)

        guard !FileManager.default.fileExists(atPath: destination.path) else {
            throw CocoaError(.fileWriteUnknown)
        }
        guard !FileManager.default.fileExists(atPath: cleanupRequest.path) else {
            throw CocoaError(.fileWriteUnknown)
        }
    }

    private func requirePinnedModel(at url: URL, identity: ModelIdentity) throws {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true else {
            throw StagingError.notRegularFile
        }
        guard values.fileSize == identity.byteCount else {
            throw StagingError.byteCountMismatch(
                expected: identity.byteCount,
                actual: values.fileSize
            )
        }
        let actualSHA256 = try sha256(at: url)
        guard actualSHA256 == identity.sha256 else {
            throw StagingError.sha256Mismatch(expected: identity.sha256, actual: actualSHA256)
        }
    }

    private func sha256(at url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()
        while true {
            let chunk = try handle.read(upToCount: 4 * 1_024 * 1_024) ?? Data()
            guard !chunk.isEmpty else { break }
            hasher.update(data: chunk)
        }

        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func makeTemporaryFixture(sourceData: Data) throws -> (
        root: URL,
        source: URL,
        destination: URL,
        partialDestination: URL,
        identity: ModelIdentity
    ) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let source = root.appendingPathComponent("source.gram")
        let destination = root.appendingPathComponent("installed.gram")
        let partialDestination = destination.appendingPathExtension(Fixture.partialInstallSuffix)
        try sourceData.write(to: source)
        return (
            root,
            source,
            destination,
            partialDestination,
            ModelIdentity(byteCount: sourceData.count, sha256: try sha256(at: source))
        )
    }
}
