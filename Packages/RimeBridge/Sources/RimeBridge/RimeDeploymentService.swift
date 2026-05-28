import Foundation
import RimeBridgeObjC

public enum RimeDeploymentMode: Sendable {
    case fullCheck
    case runtimeRecovery
}

public struct RimeDeploymentRequest: Sendable {
    public let mode: RimeDeploymentMode
    public let sharedDataURL: URL
    public let userDataURL: URL

    public init(mode: RimeDeploymentMode, sharedDataURL: URL, userDataURL: URL) {
        self.mode = mode
        self.sharedDataURL = sharedDataURL
        self.userDataURL = userDataURL
    }
}

public struct RimeDeploymentResult: Sendable {
    public let succeeded: Bool
    public let diagnosticMessage: String

    public init(succeeded: Bool, diagnosticMessage: String) {
        self.succeeded = succeeded
        self.diagnosticMessage = diagnosticMessage
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
        let succeeded = deployer.deploy(
            withSharedDataDir: request.sharedDataURL.path,
            userDataDir: request.userDataURL.path
        )
        return RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "librime \(version)"
        )
    }
}
