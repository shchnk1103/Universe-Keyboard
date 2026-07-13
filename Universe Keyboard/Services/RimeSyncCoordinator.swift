import Foundation

nonisolated struct RimeSyncResult: Sendable {
    let profile: RimeSyncProfile
    let uploadedBytes: Int
}

actor RimeSyncCoordinator {
    /// V1 只有少量标量设置。限制远端密文大小可避免异常服务响应造成无界内存开销。
    nonisolated static let maximumSettingsPackageBytes = 256 * 1024

    private let codec: RimeSyncPackageCodec
    private let maximumConflictRetries: Int

    init(codec: RimeSyncPackageCodec = RimeSyncPackageCodec(), maximumConflictRetries: Int = 2) {
        self.codec = codec
        self.maximumConflictRetries = maximumConflictRetries
    }

    func synchronize(
        localProfile: RimeSyncProfile,
        keyData: Data,
        transport: any RimeSyncTransport
    ) async throws -> RimeSyncResult {
        var lastConflict: RimeSyncError?

        for _ in 0...maximumConflictRetries {
            let remoteObject = try await transport.fetchSettings()
            let remoteProfile: RimeSyncProfile
            if let data = remoteObject.data {
                guard data.count <= Self.maximumSettingsPackageBytes else {
                    throw RimeSyncError.packageTooLarge
                }
                remoteProfile = try codec.decrypt(data: data, keyData: keyData)
            } else {
                remoteProfile = RimeSyncProfile()
            }

            let merged = try localProfile.merging(remoteProfile)
            let settingsData = try codec.encrypt(profile: merged, keyData: keyData)
            guard settingsData.count <= Self.maximumSettingsPackageBytes else {
                throw RimeSyncError.packageTooLarge
            }
            do {
                try await transport.publish(
                    formatData: codec.formatManifestData(),
                    settingsData: settingsData,
                    matching: remoteObject.eTag
                )
                return RimeSyncResult(profile: merged, uploadedBytes: settingsData.count)
            } catch RimeSyncError.remoteConflict {
                lastConflict = .remoteConflict
                continue
            }
        }

        throw lastConflict ?? RimeSyncError.remoteConflict
    }
}
