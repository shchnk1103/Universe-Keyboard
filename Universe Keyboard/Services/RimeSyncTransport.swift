import CryptoKit
import Foundation

nonisolated struct RimeSyncRemoteObject: Sendable {
    let data: Data?
    let eTag: String?
}

nonisolated protocol RimeSyncTransport: Sendable {
    func fetchSettings() async throws -> RimeSyncRemoteObject
    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws
    func deleteRemoteData() async throws
}

nonisolated protocol RimeSyncHTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

nonisolated enum RimeSyncFolderAccessError: Error {
    case preflight(stage: String, underlying: Error)
    case bookmark(underlying: Error)
}

/// 文件提供器目录的最小访问边界。
///
/// 选择目录和实际同步都通过同一套安全作用域与文件协调流程，避免“选择成功”
/// 但首次写入才发现没有权限。预检文件仅包含固定字节，且在读回后立即删除。
nonisolated enum RimeSyncFolderAccess {
    static func preflight(_ selectedFolderURL: URL) throws {
        do {
            try coordinateWriting(selectedFolderURL) { folderURL in
                let probeURL = folderURL.appendingPathComponent(
                    ".universe-rime-access-\(UUID().uuidString)",
                    isDirectory: false
                )
                let probeData = Data("Universe Keyboard sync access check".utf8)

                do {
                    try probeData.write(to: probeURL, options: .atomic)
                } catch {
                    throw RimeSyncFolderAccessError.preflight(stage: "write", underlying: error)
                }

                do {
                    guard try Data(contentsOf: probeURL, options: .mappedIfSafe) == probeData else {
                        throw RimeSyncError.accessDenied
                    }
                } catch {
                    try? FileManager.default.removeItem(at: probeURL)
                    throw RimeSyncFolderAccessError.preflight(stage: "read", underlying: error)
                }

                do {
                    // 删除也属于预检的一部分：不能确认清理能力的目录不能作为同步根。
                    try FileManager.default.removeItem(at: probeURL)
                } catch {
                    throw RimeSyncFolderAccessError.preflight(stage: "delete", underlying: error)
                }
            }
        } catch let error as RimeSyncFolderAccessError {
            throw error
        } catch {
            throw RimeSyncFolderAccessError.preflight(stage: "coordinate", underlying: error)
        }
    }

    static func bookmarkData(for selectedFolderURL: URL) throws -> Data {
        do {
            return try selectedFolderURL.bookmarkData(
                options: [],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            throw RimeSyncFolderAccessError.bookmark(underlying: error)
        }
    }

    static func diagnosticErrorCode(for error: Error) -> String {
        if let folderError = error as? RimeSyncFolderAccessError {
            switch folderError {
            case .preflight(let stage, let underlying):
                return "preflight.\(stage).\(diagnosticErrorCode(for: underlying))"
            case .bookmark(let underlying):
                return "bookmark.\(diagnosticErrorCode(for: underlying))"
            }
        }

        let nsError = error as NSError
        return "\(nsError.domain)#\(nsError.code)"
    }

    static func coordinateReading<T>(
        _ selectedFolderURL: URL,
        _ operation: (URL) throws -> T
    ) throws -> T {
        try coordinate(selectedFolderURL, writing: false, operation)
    }

    static func coordinateWriting<T>(
        _ selectedFolderURL: URL,
        _ operation: (URL) throws -> T
    ) throws -> T {
        try coordinate(selectedFolderURL, writing: true, operation)
    }

    private static func coordinate<T>(
        _ selectedFolderURL: URL,
        writing: Bool,
        _ operation: (URL) throws -> T
    ) throws -> T {
        let didStartAccess = selectedFolderURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                selectedFolderURL.stopAccessingSecurityScopedResource()
            }
        }

        let coordinator = NSFileCoordinator()
        var coordinationError: NSError?
        var operationResult: Result<T, Error>?
        let accessor: (URL) -> Void = { coordinatedFolderURL in
            operationResult = Result { try operation(coordinatedFolderURL) }
        }

        if writing {
            coordinator.coordinate(
                writingItemAt: selectedFolderURL,
                options: .forMerging,
                error: &coordinationError,
                byAccessor: accessor
            )
        } else {
            coordinator.coordinate(
                readingItemAt: selectedFolderURL,
                options: [],
                error: &coordinationError,
                byAccessor: accessor
            )
        }

        if let coordinationError { throw coordinationError }
        guard let operationResult else { throw RimeSyncError.accessDenied }
        return try operationResult.get()
    }
}

nonisolated struct URLSessionRimeSyncHTTPClient: RimeSyncHTTPClient {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RimeSyncError.transport("WebDAV 返回了无效响应。")
        }
        return (data, httpResponse)
    }
}

actor LocalFolderRimeSyncTransport: RimeSyncTransport {
    private let selectedFolderURL: URL
    private let fileManager = FileManager()

    init(selectedFolderURL: URL) {
        self.selectedFolderURL = selectedFolderURL
    }

    func fetchSettings() async throws -> RimeSyncRemoteObject {
        try withFolderReadAccess { folderURL in
            let url = settingsURL(in: folderURL)
            guard fileManager.fileExists(atPath: url.path) else {
                return RimeSyncRemoteObject(data: nil, eTag: nil)
            }
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            return RimeSyncRemoteObject(data: data, eTag: Self.digest(data))
        }
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {
        try withFolderWriteAccess { folderURL in
            let packageRootURL = packageRootURL(in: folderURL)
            let settingsURL = settingsURL(in: folderURL)
            let currentData = try? Data(contentsOf: settingsURL, options: .mappedIfSafe)
            let currentETag = currentData.map(Self.digest)
            guard currentETag == eTag else { throw RimeSyncError.remoteConflict }

            // 文件提供器（iCloud Drive、第三方网盘等）要求通过协调器使用其给出的
            // URL 写入。直接在 bookmark 原始 URL 上进行原子替换，可能出现“能建目录
            // 却不能保存 format.json”的权限错误。
            try fileManager.createDirectory(at: settingsURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try formatData.write(to: packageRootURL.appendingPathComponent("format.json"), options: .atomic)
            try settingsData.write(to: settingsURL, options: .atomic)
        }
    }

    func deleteRemoteData() async throws {
        try withFolderWriteAccess { folderURL in
            let packageRootURL = packageRootURL(in: folderURL)
            guard fileManager.fileExists(atPath: packageRootURL.path) else { return }
            try fileManager.removeItem(at: packageRootURL)
        }
    }

    private func packageRootURL(in folderURL: URL) -> URL {
        folderURL.appendingPathComponent("universe-rime-sync", isDirectory: true)
    }

    private func settingsURL(in folderURL: URL) -> URL {
        packageRootURL(in: folderURL)
            .appendingPathComponent("profiles", isDirectory: true)
            .appendingPathComponent("default", isDirectory: true)
            .appendingPathComponent("settings.json")
    }

    private func withFolderReadAccess<T>(_ operation: (URL) throws -> T) throws -> T {
        try withFolderAccess { try RimeSyncFolderAccess.coordinateReading(selectedFolderURL, operation) }
    }

    private func withFolderWriteAccess<T>(_ operation: (URL) throws -> T) throws -> T {
        try withFolderAccess { try RimeSyncFolderAccess.coordinateWriting(selectedFolderURL, operation) }
    }

    private func withFolderAccess<T>(_ operation: () throws -> T) throws -> T {
        do {
            return try operation()
        } catch let error as RimeSyncError {
            throw error
        } catch {
            let cocoaError = error as NSError
            if cocoaError.domain == NSCocoaErrorDomain,
               [CocoaError.Code.fileReadNoPermission.rawValue, CocoaError.Code.fileWriteNoPermission.rawValue]
                .contains(cocoaError.code)
            {
                throw RimeSyncError.accessDenied
            }
            throw RimeSyncError.transport("文件夹同步失败：\(error.localizedDescription)")
        }
    }

    nonisolated private static func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

actor WebDAVRimeSyncTransport: RimeSyncTransport {
    private let baseURL: URL
    private let authorization: String
    private let client: any RimeSyncHTTPClient

    init(
        baseURL: URL,
        username: String,
        password: String,
        client: any RimeSyncHTTPClient = URLSessionRimeSyncHTTPClient()
    ) {
        self.baseURL = baseURL
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        self.authorization = "Basic \(credential)"
        self.client = client
    }

    func fetchSettings() async throws -> RimeSyncRemoteObject {
        var request = request(url: settingsURL, method: "GET")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let (data, response) = try await perform(request)
        switch response.statusCode {
        case 200:
            return RimeSyncRemoteObject(data: data, eTag: response.value(forHTTPHeaderField: "ETag"))
        case 404:
            return RimeSyncRemoteObject(data: nil, eTag: nil)
        default:
            throw httpError(response)
        }
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {
        try await ensureCollections()
        try await put(formatData, at: baseURL.appendingPathComponent("format.json"), matching: nil, createOnly: false)
        try await put(settingsData, at: settingsURL, matching: eTag, createOnly: eTag == nil)
    }

    func deleteRemoteData() async throws {
        let (_, response) = try await perform(request(url: baseURL, method: "DELETE"))
        guard [200, 204, 404].contains(response.statusCode) else {
            throw httpError(response)
        }
    }

    private var settingsURL: URL {
        baseURL
            .appendingPathComponent("profiles", isDirectory: true)
            .appendingPathComponent("default", isDirectory: true)
            .appendingPathComponent("settings.json")
    }

    private func ensureCollections() async throws {
        let profiles = baseURL.appendingPathComponent("profiles", isDirectory: true)
        let defaultProfile = profiles.appendingPathComponent("default", isDirectory: true)
        for url in [baseURL, profiles, defaultProfile] {
            let (_, response) = try await perform(request(url: url, method: "MKCOL"))
            guard [200, 201, 204, 405].contains(response.statusCode) else {
                throw httpError(response)
            }
        }
    }

    private func put(_ data: Data, at url: URL, matching eTag: String?, createOnly: Bool) async throws {
        var request = request(url: url, method: "PUT")
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let eTag {
            request.setValue(eTag, forHTTPHeaderField: "If-Match")
        } else if createOnly {
            request.setValue("*", forHTTPHeaderField: "If-None-Match")
        }
        let (_, response) = try await perform(request)
        if response.statusCode == 412 { throw RimeSyncError.remoteConflict }
        guard [200, 201, 204].contains(response.statusCode) else {
            throw httpError(response)
        }
    }

    private func request(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            return try await client.data(for: request)
        } catch let error as RimeSyncError {
            throw error
        } catch {
            throw RimeSyncError.transport("WebDAV 连接失败：\(error.localizedDescription)")
        }
    }

    private func httpError(_ response: HTTPURLResponse) -> RimeSyncError {
        switch response.statusCode {
        case 401, 403:
            return .transport("WebDAV 认证失败，请检查账号和权限。")
        case 507:
            return .transport("WebDAV 空间不足。")
        default:
            return .transport("WebDAV 请求失败（HTTP \(response.statusCode)）。")
        }
    }
}
