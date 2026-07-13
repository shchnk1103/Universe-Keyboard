import CryptoKit
import Foundation
import Security

nonisolated struct RimeSyncPackageCodec: Sendable {
    private static let additionalAuthenticatedData = Data("universe-rime-sync/v1".utf8)

    func encrypt(profile: RimeSyncProfile, keyData: Data) throws -> Data {
        guard keyData.count == 32 else { throw RimeSyncError.invalidRecoveryCode }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let plaintext = try encoder.encode(profile)
        let sealed = try ChaChaPoly.seal(
            plaintext,
            using: SymmetricKey(data: keyData),
            authenticating: Self.additionalAuthenticatedData
        )
        let combined = sealed.combined

        return try encoder.encode(
            RimeSyncEncryptedSettings(
                version: 1,
                algorithm: "chacha20-poly1305",
                combined: combined.base64EncodedString()
            )
        )
    }

    func decrypt(data: Data, keyData: Data) throws -> RimeSyncProfile {
        guard keyData.count == 32 else { throw RimeSyncError.invalidRecoveryCode }
        do {
            let envelope = try JSONDecoder().decode(RimeSyncEncryptedSettings.self, from: data)
            guard envelope.version == 1, envelope.algorithm == "chacha20-poly1305",
                  let combined = Data(base64Encoded: envelope.combined)
            else {
                throw RimeSyncError.unsupportedFormat
            }
            let box = try ChaChaPoly.SealedBox(combined: combined)
            let plaintext = try ChaChaPoly.open(
                box,
                using: SymmetricKey(data: keyData),
                authenticating: Self.additionalAuthenticatedData
            )
            let profile = try JSONDecoder().decode(RimeSyncProfile.self, from: plaintext)
            guard profile.schemaVersion == RimeSyncProfile.currentSchemaVersion else {
                throw RimeSyncError.unsupportedFormat
            }
            return profile
        } catch let error as RimeSyncError {
            throw error
        } catch {
            throw RimeSyncError.corruptedPackage
        }
    }

    func formatManifestData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(RimeSyncFormatManifest.current)
    }

    static func generateKey() -> Data {
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }

    static func recoveryCode(for keyData: Data) -> String {
        keyData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func keyData(fromRecoveryCode recoveryCode: String) throws -> Data {
        let compact = recoveryCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = String(repeating: "=", count: (4 - compact.count % 4) % 4)
        guard let data = Data(base64Encoded: compact + padding), data.count == 32 else {
            throw RimeSyncError.invalidRecoveryCode
        }
        return data
    }
}

actor RimeSyncSecretStore {
    private let service = "com.DoubleShy0N.Universe-Keyboard.rime-sync"

    func data(for account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw RimeSyncError.accessDenied
        }
        return data
    }

    func set(_ data: Data, for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            var insertion = query
            insertion.merge(attributes) { _, new in new }
            guard SecItemAdd(insertion as CFDictionary, nil) == errSecSuccess else {
                throw RimeSyncError.accessDenied
            }
        } else if updateStatus != errSecSuccess {
            throw RimeSyncError.accessDenied
        }
    }

    func remove(_ account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw RimeSyncError.accessDenied
        }
    }
}
