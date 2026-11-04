import XCTest

@testable import Universe_Keyboard

@MainActor
final class WanxiangT9DeploymentSupportTests: XCTestCase {
    private let schemaFile = "wanxiang_t9i.schema.yaml"

    func testFirstInstallRewritesSourceAndDeletesCompiledProducts() throws {
        let fixture = try Fixture()
        try fixture.writeSource(Self.oneProcessor)
        try "old: t9_processor\n".write(
            to: fixture.sharedBuild.appendingPathComponent(schemaFile), atomically: true, encoding: .utf8)
        try "old: t9_processor\n".write(
            to: fixture.userBuild.appendingPathComponent(schemaFile), atomically: true, encoding: .utf8)

        let result = WanxiangT9DeploymentSupport.prepare(
            sharedDataURL: fixture.shared,
            userDataURL: fixture.user
        )
        XCTAssertFalse(result.failed)
        XCTAssertEqual(result.steps.map(\.reason), ["rewritten", "removed"])
        let written = try String(contentsOf: fixture.source, encoding: .utf8)
        XCTAssertFalse(written.contains("t9_processor"))
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: fixture.sharedBuild.appendingPathComponent(schemaFile).path))
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: fixture.userBuild.appendingPathComponent(schemaFile).path))
    }

    func testSecondPrepareIsANoOp() throws {
        let fixture = try Fixture()
        try fixture.writeSource(Self.oneProcessor)
        _ = WanxiangT9DeploymentSupport.prepare(sharedDataURL: fixture.shared, userDataURL: fixture.user)
        let afterFirst = try Data(contentsOf: fixture.source)
        let second = WanxiangT9DeploymentSupport.prepare(sharedDataURL: fixture.shared, userDataURL: fixture.user)
        XCTAssertFalse(second.failed)
        XCTAssertEqual(second.steps.first?.reason, "alreadyCompatible")
        XCTAssertEqual(try Data(contentsOf: fixture.source), afterFirst)
    }

    func testDeleteFailureStopsBeforeClaimingRemoval() throws {
        let fixture = try Fixture()
        try fixture.writeSource(Self.oneProcessor)
        let stale = fixture.sharedBuild.appendingPathComponent(schemaFile)
        try "stale\n".write(to: stale, atomically: true, encoding: .utf8)
        var files = WanxiangT9Files.live
        files.remove = { _ in throw CocoaError(.fileWriteNoPermission) }
        let result = WanxiangT9DeploymentSupport.prepare(
            sharedDataURL: fixture.shared,
            userDataURL: fixture.user,
            files: files
        )
        XCTAssertTrue(result.failed)
        XCTAssertEqual(result.steps.last?.step, "deleteBuild")
        XCTAssertEqual(result.steps.last?.reason, "deleteFailed")
        XCTAssertTrue(FileManager.default.fileExists(atPath: stale.path))
    }

    func testMissingCompiledSchemaFailsRecheck() throws {
        let fixture = try Fixture()
        let check = WanxiangT9DeploymentSupport.recheckCompiled(
            sharedDataURL: fixture.shared,
            userDataURL: fixture.user
        )
        XCTAssertTrue(check.failed)
        XCTAssertEqual(check.step.reason, "compiledMissing")
    }

    func testCompiledProcessorFailsRecheck() throws {
        let fixture = try Fixture()
        try "processors:\n  - t9_processor\n".write(
            to: fixture.sharedBuild.appendingPathComponent(schemaFile),
            atomically: true,
            encoding: .utf8
        )
        let check = WanxiangT9DeploymentSupport.recheckCompiled(
            sharedDataURL: fixture.shared,
            userDataURL: fixture.user
        )
        XCTAssertTrue(check.failed)
        XCTAssertEqual(check.step.step, "recheckCompiled")
        XCTAssertEqual(check.step.reason, "t9ProcessorPresent")
    }

    private static let oneProcessor = """
        engine:
          processors:
            - ascii_composer
            - t9_processor
            - speller

        """

    private struct Fixture {
        let root: URL
        let shared: URL
        let user: URL
        let sharedBuild: URL
        let userBuild: URL
        var source: URL { shared.appendingPathComponent("wanxiang_t9i.schema.yaml") }

        init() throws {
            root = FileManager.default.temporaryDirectory.appendingPathComponent(
                "wanxiang-t9-\(UUID().uuidString)", isDirectory: true)
            shared = root.appendingPathComponent("shared", isDirectory: true)
            user = root.appendingPathComponent("user", isDirectory: true)
            sharedBuild = shared.appendingPathComponent("build", isDirectory: true)
            userBuild = user.appendingPathComponent("build", isDirectory: true)
            try FileManager.default.createDirectory(at: sharedBuild, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: userBuild, withIntermediateDirectories: true)
        }

        func writeSource(_ text: String) throws {
            try text.write(to: source, atomically: true, encoding: .utf8)
        }
    }
}
