import CryptoKit
import Foundation
import XCTest

/// Test-only bridge for the TD-012 G2 physical-device spike.
///
/// `devicectl` can transfer bytes only into the App Group's allowed `tmp`
/// subtree, while RIME resolves shared resources from the root-level
/// `Rime/shared` directory. These tests perform that final same-container move
/// only when an exact, pre-pinned file (or cleanup request) is present.
/// Normal CI and ordinary device test runs skip both methods.
final class TD012LMDGDeviceStagingTests: XCTestCase {
    private enum Fixture {
        static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
        static let modelName = "wanxiang-lts-zh-hans.gram"
        static let expectedByteCount = 420_251_692
        static let expectedSHA256 = "90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66"

        static let stagingRelativePath = "tmp/td012-g2/\(modelName)"
        static let cleanupRequestRelativePath = "tmp/td012-g2/cleanup.request"
        static let installedRelativePath = "Rime/shared/\(modelName)"
        static let partialInstallSuffix = ".td012-staging"
    }

    func testStagePinnedModelForAuthorizedPhysicalDeviceSpike() throws {
        #if targetEnvironment(simulator)
            throw XCTSkip("TD-012 G2 staging is physical-device-only")
        #else
            let container = try appGroupContainer()
            let source = container.appendingPathComponent(Fixture.stagingRelativePath)
            guard FileManager.default.fileExists(atPath: source.path) else {
                throw XCTSkip("No explicitly transferred TD-012 G2 model fixture")
            }

            try assertPinnedModel(at: source)

            let destination = container.appendingPathComponent(Fixture.installedRelativePath)
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: destination.path),
                "Refusing to replace an existing grammar model during the G2 spike"
            )

            let partialDestination = destination.appendingPathExtension(Fixture.partialInstallSuffix)
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: partialDestination.path),
                "Unexpected prior TD-012 staging residue requires manual review"
            )

            try FileManager.default.createDirectory(
                at: destination.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            // The source and destination share one App Group volume. Move first to
            // a non-resolvable name, revalidate, then reveal the final model name.
            try FileManager.default.moveItem(at: source, to: partialDestination)
            try assertPinnedModel(at: partialDestination)
            try FileManager.default.moveItem(at: partialDestination, to: destination)
            try assertPinnedModel(at: destination)
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
            try assertPinnedModel(at: destination)
            try FileManager.default.removeItem(at: destination)
            try FileManager.default.removeItem(at: cleanupRequest)

            XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
            XCTAssertFalse(FileManager.default.fileExists(atPath: cleanupRequest.path))
        #endif
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

    private func assertPinnedModel(at url: URL) throws {
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        XCTAssertEqual(values.isRegularFile, true)
        XCTAssertEqual(values.fileSize, Fixture.expectedByteCount)
        XCTAssertEqual(try sha256(at: url), Fixture.expectedSHA256)
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
}
