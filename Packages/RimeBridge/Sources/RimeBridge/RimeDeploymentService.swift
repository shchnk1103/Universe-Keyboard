import Foundation
import KeyboardCore
import RimeBridgeObjC

public enum RimeDeploymentMode: Sendable {
    case fullCheck
    case runtimeRecovery
    #if DEBUG
        /// Isolated test-fixture compilation; never represents product deployment success.
        case testFixtureMaintenanceOnly
    #endif
}

public struct RimeDeploymentRequest: Sendable {
    public let mode: RimeDeploymentMode
    public let sharedDataURL: URL
    public let userDataURL: URL
    public let runtimeSmokeSchemaID: String?

    public init(
        mode: RimeDeploymentMode,
        sharedDataURL: URL,
        userDataURL: URL,
        runtimeSmokeSchemaID: String? = nil
    ) {
        self.mode = mode
        self.sharedDataURL = sharedDataURL
        self.userDataURL = userDataURL
        self.runtimeSmokeSchemaID = runtimeSmokeSchemaID
    }
}

public struct RimeDeploymentResult: Sendable {
    public let succeeded: Bool
    public let diagnosticMessage: String
    /// Generic active-schema smoke. `nil` means the caller did not request one.
    public let runtimeSmokePassed: Bool?
    /// Fog-specific Lua capability smoke, kept separate from basic typing readiness.
    public let luaRuntimeSmokePassed: Bool?

    public init(
        succeeded: Bool,
        diagnosticMessage: String,
        runtimeSmokePassed: Bool? = nil,
        luaRuntimeSmokePassed: Bool? = nil
    ) {
        self.succeeded = succeeded
        self.diagnosticMessage = diagnosticMessage
        self.runtimeSmokePassed = runtimeSmokePassed
        self.luaRuntimeSmokePassed = luaRuntimeSmokePassed
    }
}

public protocol RimeDeploymentServicing: Sendable {
    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult
}

/// Serializes full RIME deployments away from the keyboard input session.
///
/// The main app is the only caller of `.fullCheck`; the keyboard continues to
/// use its lightweight session recovery path during input.
public actor RimeDeploymentService: RimeDeploymentServicing {
    struct MaintenanceResult: Sendable {
        let succeeded: Bool
        let librimeVersion: String
    }

    typealias DeployOperation = @Sendable (String, String) -> MaintenanceResult
    typealias SchemaSmokeOperation = @Sendable (String, String, String) -> RimeSchemaRuntimeSmokeProbe.Result
    typealias LuaSmokeOperation = @Sendable (String, String, String) -> RimeLuaRuntimeSmokeProbe.Result

    private let deployOperation: DeployOperation
    private let schemaSmokeOperation: SchemaSmokeOperation
    private let luaSmokeOperation: LuaSmokeOperation

    public init() {
        deployOperation = { sharedDataDir, userDataDir in
            let deployer = RimeDeployer()
            let version = deployer.librimeVersion()
            let succeeded = deployer.deploy(
                withSharedDataDir: sharedDataDir,
                userDataDir: userDataDir
            )
            return MaintenanceResult(succeeded: succeeded, librimeVersion: version)
        }
        schemaSmokeOperation = { sharedDataDir, userDataDir, schemaID in
            RimeSchemaRuntimeSmokeProbe.run(
                sharedDataDir: sharedDataDir,
                userDataDir: userDataDir,
                schemaID: schemaID
            )
        }
        luaSmokeOperation = { sharedDataDir, userDataDir, schemaID in
            RimeLuaRuntimeSmokeProbe.run(
                sharedDataDir: sharedDataDir,
                userDataDir: userDataDir,
                schemaID: schemaID
            )
        }
    }

    init(
        deployOperation: @escaping DeployOperation,
        schemaSmokeOperation: @escaping SchemaSmokeOperation,
        luaSmokeOperation: @escaping LuaSmokeOperation
    ) {
        self.deployOperation = deployOperation
        self.schemaSmokeOperation = schemaSmokeOperation
        self.luaSmokeOperation = luaSmokeOperation
    }

    public func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        switch request.mode {
        case .fullCheck:
            break
        case .runtimeRecovery:
            return RimeDeploymentResult(
                succeeded: false,
                diagnosticMessage: "Runtime recovery is owned by the keyboard session engine."
            )
        #if DEBUG
            case .testFixtureMaintenanceOnly:
                let result = deployOperation(request.sharedDataURL.path, request.userDataURL.path)
                return RimeDeploymentResult(
                    succeeded: result.succeeded,
                    diagnosticMessage: "librime \(result.librimeVersion), isolated test fixture"
                )
        #endif
        }

        guard
            let schemaID = request.runtimeSmokeSchemaID,
            RimeSchemaDeploymentInputValidator.isReady(
                sharedDataURL: request.sharedDataURL,
                userDataURL: request.userDataURL,
                schemaID: schemaID
            )
        else {
            return RimeDeploymentResult(
                succeeded: false,
                diagnosticMessage: "Active schema deployment input is incomplete."
            )
        }
        let luaRegisteredBeforeDeploy = RimeBridgeCapabilities.luaModuleRegistered
        Logger.shared.info(
            "deployRimeConfig: lua runtime before deploy registered=\(luaRegisteredBeforeDeploy) "
                + "componentCount=\(RimeBridgeCapabilities.luaComponentRegistrySummary.count)",
            category: .deployment
        )
        let maintenanceResult = deployOperation(
            request.sharedDataURL.path,
            request.userDataURL.path
        )
        let deploymentSucceeded = maintenanceResult.succeeded
        let luaRegisteredAfterDeploy = RimeBridgeCapabilities.luaModuleRegistered
        Logger.shared.info(
            "deployRimeConfig: lua runtime after deploy registered=\(luaRegisteredAfterDeploy) "
                + "componentCount=\(RimeBridgeCapabilities.luaComponentRegistrySummary.count)",
            category: .deployment
        )
        var runtimeSmokePassed: Bool?
        if deploymentSucceeded, let schemaID = request.runtimeSmokeSchemaID {
            let smokeResult = schemaSmokeOperation(
                request.sharedDataURL.path,
                request.userDataURL.path,
                schemaID
            )
            runtimeSmokePassed = smokeResult.passed
            Logger.shared.info(
                "deployRimeConfig: schema smoke completed passed=\(smokeResult.passed) "
                    + "selected=\(smokeResult.selectedRequestedSchema) "
                    + "compositionPresent=\(smokeResult.compositionPresent) "
                    + "rawInputMatched=\(smokeResult.rawInputMatched) "
                    + "candidateCount=\(smokeResult.candidateCount) "
                    + "hasHanCandidate=\(smokeResult.hasHanCandidate) "
                    + "unexpectedCommit=\(smokeResult.unexpectedCommit)",
                category: .deployment
            )
        }
        var luaRuntimeSmokePassed: Bool?
        if deploymentSucceeded, runtimeSmokePassed == true, request.runtimeSmokeSchemaID == "rime_ice" {
            let smokeResult = luaSmokeOperation(
                request.sharedDataURL.path,
                request.userDataURL.path,
                "rime_ice"
            )
            luaRuntimeSmokePassed = smokeResult.passed
            Logger.shared.info(
                "deployRimeConfig: lua smoke completed passed=\(smokeResult.passed) "
                    + "registered=\(smokeResult.luaModuleRegistered) "
                    + "caseCount=\(smokeResult.caseResults.count) "
                    + "dynamicCaseCount=\(smokeResult.caseResults.filter(\.dynamicCandidateFound).count)",
                category: .deployment
            )
        }
        let succeeded = deploymentSucceeded && runtimeSmokePassed == true
        return RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "librime \(maintenanceResult.librimeVersion), "
                + "luaRuntimeRegistered=\(luaRegisteredAfterDeploy)",
            runtimeSmokePassed: runtimeSmokePassed,
            luaRuntimeSmokePassed: luaRuntimeSmokePassed
        )
    }
}
