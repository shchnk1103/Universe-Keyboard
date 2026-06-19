import Foundation
import KeyboardCore
import RimeBridgeObjC

public enum RimeDeploymentMode: Sendable {
    case fullCheck
    case runtimeRecovery
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
    public let runtimeSmokePassed: Bool?

    public init(succeeded: Bool, diagnosticMessage: String, runtimeSmokePassed: Bool? = nil) {
        self.succeeded = succeeded
        self.diagnosticMessage = diagnosticMessage
        self.runtimeSmokePassed = runtimeSmokePassed
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
    public init() {}

    public func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        guard case .fullCheck = request.mode else {
            return RimeDeploymentResult(
                succeeded: false,
                diagnosticMessage: "Runtime recovery is owned by the keyboard session engine."
            )
        }

        let deployer = RimeDeployer()
        let version = deployer.librimeVersion()
        let luaRegisteredBeforeDeploy = RimeBridgeCapabilities.luaModuleRegistered
        let luaComponentsBeforeDeploy = RimeBridgeCapabilities.luaComponentRegistrySummary.joined(separator: "+")
        Logger.shared.info(
            "deployRimeConfig: lua runtime before deploy registered=\(luaRegisteredBeforeDeploy);componentSnapshot=\(luaComponentsBeforeDeploy)",
            category: .deployment
        )
        let succeeded = deployer.deploy(
            withSharedDataDir: request.sharedDataURL.path,
            userDataDir: request.userDataURL.path
        )
        let luaRegisteredAfterDeploy = RimeBridgeCapabilities.luaModuleRegistered
        let luaComponentsAfterDeploy = RimeBridgeCapabilities.luaComponentRegistrySummary.joined(separator: "+")
        Logger.shared.info(
            "deployRimeConfig: lua runtime after deploy registered=\(luaRegisteredAfterDeploy);postFinalizeComponentSnapshot=\(luaComponentsAfterDeploy)",
            category: .deployment
        )
        var runtimeSmokePassed: Bool?
        if succeeded, request.runtimeSmokeSchemaID == "rime_ice" {
            let smokeResult = RimeLuaRuntimeSmokeProbe.run(
                sharedDataDir: request.sharedDataURL.path,
                userDataDir: request.userDataURL.path,
                schemaID: "rime_ice"
            )
            runtimeSmokePassed = smokeResult.passed
            Logger.shared.info(
                "deployRimeConfig: \(smokeResult.developerSummary)",
                category: .deployment
            )
            let runtimeLogLines = RimeRuntimeLogSnapshot.relevantLines(in: request.userDataURL)
            if runtimeLogLines.isEmpty {
                Logger.shared.info("deployRimeConfig: rime runtime log snapshot empty", category: .deployment)
            } else {
                Logger.shared.info(
                    "deployRimeConfig: rime runtime log snapshot: \(runtimeLogLines.joined(separator: " || "))",
                    category: .deployment
                )
            }
        }
        return RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "librime \(version), luaRuntimeRegistered=\(luaRegisteredAfterDeploy)",
            runtimeSmokePassed: runtimeSmokePassed
        )
    }
}
