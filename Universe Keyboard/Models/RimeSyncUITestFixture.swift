#if DEBUG
    import Foundation

    enum RimeSyncUITestFixture {
        static let unconfiguredArgument = "--rime-sync-ui-unconfigured"
        static let localFolderArgument = "--rime-sync-ui-local-folder"
        static let localFolderPickerArgument = "--rime-sync-ui-local-folder-picker"
        static let localFolderIntegrationArgument = "--rime-sync-ui-local-folder-integration"
        static let folderRepairArgument = "--rime-sync-ui-folder-repair"
        static let webDAVArgument = "--rime-sync-ui-webdav"
        static let succeededStatusArgument = "--rime-sync-ui-status-succeeded"
        static let conflictStatusArgument = "--rime-sync-ui-status-conflict"
        static let corruptedStatusArgument = "--rime-sync-ui-status-corrupted"
        static let authenticationFailureArgument = "--rime-sync-ui-authentication-failure"
        static let wrongKeyArgument = "--rime-sync-ui-wrong-key"
        static let deletionFailureArgument = "--rime-sync-ui-deletion-failure"
        static let defaultsSuiteArgument = "--rime-sync-ui-defaults-suite"

        static func isRequested(
            arguments: [String] = ProcessInfo.processInfo.arguments
        ) -> Bool {
            [
                unconfiguredArgument,
                localFolderArgument,
                localFolderPickerArgument,
                localFolderIntegrationArgument,
                folderRepairArgument,
                webDAVArgument,
                succeededStatusArgument,
                conflictStatusArgument,
                corruptedStatusArgument,
                authenticationFailureArgument,
                wrongKeyArgument,
                deletionFailureArgument,
            ].contains { arguments.contains($0) }
        }

        static func makeViewModelIfRequested(
            rimeStore: RimeSettingsStore,
            arguments: [String] = ProcessInfo.processInfo.arguments
        ) -> RimeSyncViewModel? {
            guard isRequested(arguments: arguments) else { return nil }
            guard let suiteName = value(after: defaultsSuiteArgument, in: arguments),
                let defaults = UserDefaults(suiteName: suiteName)
            else {
                preconditionFailure("RIME sync UI tests require an isolated defaults suite.")
            }

            defaults.removePersistentDomain(forName: suiteName)

            // Keep production sync orchestration in the path, but isolate test
            // credentials from Keychain state that survives Simulator launches.
            if arguments.contains(localFolderIntegrationArgument) {
                return RimeSyncViewModel(
                    rimeStore: rimeStore,
                    defaults: defaults,
                    secretStore: RimeSyncUITestSecretStore(),
                    keyboardActivityDefaults: defaults,
                    backgroundSchedulingEnabled: false
                )
            }

            seedConfiguration(in: defaults, arguments: arguments)

            let secretStore = RimeSyncUITestSecretStore(
                values: seededSecrets(arguments: arguments)
            )
            let transportError = transportError(arguments: arguments)

            return RimeSyncViewModel(
                rimeStore: rimeStore,
                defaults: defaults,
                secretStore: secretStore,
                syncTransportFactory: {
                    RimeSyncUITestTransport(deletionError: transportError, fetchError: transportError)
                },
                keyboardActivityDefaults: defaults,
                backgroundSchedulingEnabled: false
            )
        }

        static func applyStatusIfRequested(
            to model: RimeSyncViewModel,
            arguments: [String] = ProcessInfo.processInfo.arguments
        ) {
            if arguments.contains(succeededStatusArgument) {
                model.status = .succeeded(Date(), .standardRimeAndPrivateSettings)
            } else if arguments.contains(conflictStatusArgument) {
                model.status = .failed(RimeSyncError.remoteConflict.localizedDescription)
            } else if arguments.contains(corruptedStatusArgument) {
                model.recoveryCode = ""
                model.status = .failed(RimeSyncError.corruptedPackage.localizedDescription)
            } else if arguments.contains(wrongKeyArgument) {
                model.recoveryCode = ""
                model.status = .failed(RimeSyncError.corruptedPackage.localizedDescription)
            }
        }

        private static func seedConfiguration(in defaults: UserDefaults, arguments: [String]) {
            if arguments.contains(webDAVArgument)
                || arguments.contains(authenticationFailureArgument)
                || arguments.contains(wrongKeyArgument)
                || arguments.contains(deletionFailureArgument)
            {
                defaults.set(RimeSyncProvider.webDAV.rawValue, forKey: RimeSyncStorageKey.provider)
                defaults.set("https://sync.example.test/dav", forKey: RimeSyncStorageKey.webDAVURL)
                defaults.set("ui-test-user", forKey: RimeSyncStorageKey.webDAVUsername)
                return
            }

            if arguments.contains(localFolderPickerArgument) {
                defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
                return
            }

            guard
                arguments.contains(localFolderArgument)
                    || arguments.contains(folderRepairArgument)
            else {
                return
            }

            // Simulate a bookmark-backed selection without resolving a real folder.
            defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
            defaults.set(Data([0x01]), forKey: RimeSyncStorageKey.folderBookmark)
            defaults.set("UI Test Folder", forKey: RimeSyncStorageKey.folderName)

            if arguments.contains(folderRepairArgument) {
                defaults.set(true, forKey: RimeSyncStorageKey.folderSelectionNeedsRepair)
            } else {
                defaults.set(Date(), forKey: RimeSyncStorageKey.standardRimeLastSuccess)
            }
        }

        private static func seededSecrets(arguments: [String]) -> [String: Data] {
            guard
                arguments.contains(where: {
                    [
                        webDAVArgument,
                        authenticationFailureArgument,
                        wrongKeyArgument,
                        deletionFailureArgument,
                    ].contains($0)
                })
            else { return [:] }

            // Dummy-only key material and password; the fixture never accesses production Keychain.
            return [
                "encryption-key": Data(repeating: 0x01, count: 32),
                "webdav-password": Data("ui-test-password".utf8),
            ]
        }

        private static func transportError(arguments: [String]) -> RimeSyncError? {
            if arguments.contains(authenticationFailureArgument) {
                return .transport("WebDAV 认证失败，请检查账号和权限。")
            }
            if arguments.contains(wrongKeyArgument) {
                return .corruptedPackage
            }
            if arguments.contains(deletionFailureArgument) {
                return .transport("WebDAV 认证失败，请检查账号和权限。")
            }
            return nil
        }

        private static func value(after key: String, in arguments: [String]) -> String? {
            guard let index = arguments.firstIndex(of: key), arguments.indices.contains(index + 1)
            else {
                return nil
            }
            return arguments[index + 1]
        }
    }

    /// Keeps UI tests away from credentials stored by the production app.
    actor RimeSyncUITestSecretStore: RimeSyncSecretStoring {
        private var values: [String: Data]

        init(values: [String: Data] = [:]) {
            self.values = values
        }

        func data(for account: String) async throws -> Data? {
            values[account]
        }

        func set(_ data: Data, for account: String) async throws {
            values[account] = data
        }

        func remove(_ account: String) async throws {
            values.removeValue(forKey: account)
        }
    }

    /// A deterministic transport fake: tests exercise UI state transitions, never a provider account.
    actor RimeSyncUITestTransport: RimeSyncTransport {
        private let deletionError: RimeSyncError?
        private let fetchError: RimeSyncError?

        init(deletionError: RimeSyncError?, fetchError: RimeSyncError?) {
            self.deletionError = deletionError
            self.fetchError = fetchError
        }

        func fetchSettings() async throws -> RimeSyncRemoteObject {
            if let fetchError { throw fetchError }
            return RimeSyncRemoteObject(data: nil, eTag: nil)
        }

        func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {}

        func deleteRemoteData() async throws {
            if let deletionError { throw deletionError }
        }
    }
#endif
