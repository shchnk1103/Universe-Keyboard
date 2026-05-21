import Foundation
import Combine
import KeyboardCore

// MARK: - Schema metadata

struct SchemaMetadata: Codable, Identifiable, Equatable {
    var id: String { schemaID }
    let schemaID: String
    let name: String
    let description: String
    let source: SchemaSource
    let version: String?
    var installed: Bool
    let requiresLua: Bool
    let downloadSize: String

    enum SchemaSource: String, Codable { case builtin, downloaded }
}

enum DownloadState: Equatable {
    case idle
    case fetchingReleaseInfo
    case downloading(progress: Double)
    case extracting
    case postProcessing
    case deploying
    case completed
    case failed(String)
}

// MARK: - Schema Manager

@MainActor
final class SchemaManager: ObservableObject {

    private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    private let defaults: UserDefaults
    private let fm = FileManager.default

    @Published var activeSchemaID: String
    @Published var schemas: [SchemaMetadata] = []
    @Published var rimeIceDownloadState: DownloadState = .idle
    @Published var rimeIceLicenseAccepted: Bool = false
    @Published var rimeIceVersion: String?

    private var downloadTask: URLSessionTask?
    private var currentDownloadTask: Task<Void, Never>?

    init() {
        self.defaults = UserDefaults(suiteName: appGroupID) ?? .standard
        self.activeSchemaID = defaults.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        self.rimeIceLicenseAccepted = defaults.bool(forKey: "rime_ice_license_accepted")
        self.rimeIceVersion = defaults.string(forKey: "rime_ice_version")
        refreshSchemaList()
    }

    // MARK: - Schema list

    func refreshSchemaList() {
        let installed = defaults.bool(forKey: "rime_ice_installed") && rimeIceFilesExist()

        var list: [SchemaMetadata] = [
            SchemaMetadata(
                schemaID: "luna_pinyin",
                name: "朙月拼音",
                description: "RIME 官方基础拼音方案，内置于 App。词库较小，适合测试和快速输入。",
                source: .builtin,
                version: nil,
                installed: true,
                requiresLua: false,
                downloadSize: "内置"
            )
        ]

        if installed || defaults.bool(forKey: "rime_ice_installed") {
            let version = rimeIceVersion ?? defaults.string(forKey: "rime_ice_version")
            list.append(SchemaMetadata(
                schemaID: "rime_ice",
                name: "雾凇拼音",
                description: "社区维护的高质量简体词库，词条丰富、更新活跃。需要下载约 16 MB。",
                source: .downloaded,
                version: version,
                installed: installed,
                requiresLua: true,
                downloadSize: "16 MB"
            ))
        }

        if !installed && !defaults.bool(forKey: "rime_ice_installed") {
            list.append(SchemaMetadata(
                schemaID: "rime_ice",
                name: "雾凇拼音",
                description: "社区维护的高质量简体词库，词条丰富、更新活跃。需要下载约 16 MB。",
                source: .downloaded,
                version: nil,
                installed: false,
                requiresLua: true,
                downloadSize: "16 MB"
            ))
        }

        // 去重
        var seen: Set<String> = []
        schemas = list.filter { seen.insert($0.schemaID + ($0.version ?? "") + String($0.installed)).inserted }
    }

    // MARK: - Schema switching

    func switchToSchema(_ schemaID: String) {
        guard activeSchemaID != schemaID else { return }
        activeSchemaID = schemaID
        defaults.set(schemaID, forKey: "rime_active_schema")
        requestDeploy()
        refreshSchemaList()
    }

    // MARK: - License

    func acceptLicense() {
        rimeIceLicenseAccepted = true
        defaults.set(true, forKey: "rime_ice_license_accepted")
    }

    // MARK: - Download

    func startDownload() {
        switch rimeIceDownloadState {
        case .idle, .failed: break
        default: return
        }
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload()
        }
    }

    /// 强制重新下载（清除缓存版本和 ETag，即使已安装也重新下载）
    func forceRedownload() {
        switch rimeIceDownloadState {
        case .idle, .failed: break
        default: return
        }
        defaults.removeObject(forKey: "rime_ice_etag")
        defaults.removeObject(forKey: "rime_ice_version")
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload()
        }
    }

    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        currentDownloadTask?.cancel()
        currentDownloadTask = nil
        rimeIceDownloadState = .idle
    }

    private func fetchAndDownload() async {
        do {
            // 1. 获取最新 release 信息
            let releaseURL = try await fetchLatestReleaseURL()
            guard let url = releaseURL else {
                throw DownloadError.networkError("无法获取最新版本信息")
            }

            rimeIceDownloadState = .downloading(progress: 0)

            // 2. 下载
            let (tempURL, response) = try await downloadZip(from: url)
            let expectedSize = response.expectedContentLength
            guard expectedSize > 0 || expectedSize == -1 else {
                throw DownloadError.networkError("服务器未提供文件大小")
            }
            let diskNeeded = expectedSize > 0 ? expectedSize * 3 + 100_000_000 : 200_000_000

            // 3. 检查磁盘空间
            try checkDiskSpace(needed: diskNeeded)

            rimeIceDownloadState = .extracting

            // 4. 解压到临时目录
            let extractDir = fm.temporaryDirectory.appendingPathComponent("rime_ice_extract")
            try? fm.removeItem(at: extractDir)
            try fm.createDirectory(at: extractDir, withIntermediateDirectories: true)

            let extractedFiles = try Unzip.extract(zipPath: tempURL.path, to: extractDir)

            // 5. 查找并处理 schema 文件
            guard let schemaURL = findFile(named: "rime_ice.schema.yaml", in: extractDir) else {
                throw DownloadError.corruptArchive // "缺少 rime_ice.schema.yaml"
            }

            rimeIceDownloadState = .postProcessing
            try await Task.sleep(nanoseconds: 200_000_000) // 让 UI 刷新

            // 6. Lua 可用性检查 — librime-lua 已编译链接时保留 Lua
            // 仅在 rime_lua_available 明确为 false 时剥离
            // object(forKey:) 区分 nil（首次，键盘未启动）和 false（明确禁用）
            let luaAvailable = UserDefaults(suiteName: appGroupID)?.object(forKey: "rime_lua_available") as? Bool
            if luaAvailable == false {
                let schemaContent = try String(contentsOf: schemaURL, encoding: .utf8)
                let processed = RimeConfigPostProcessor.stripLuaDependencies(from: schemaContent)
                guard RimeConfigPostProcessor.validateStrippedSchema(processed) else {
                    throw DownloadError.postProcessingFailed("剥离 Lua 后 schema 无效")
                }
                try processed.write(to: schemaURL, atomically: true, encoding: .utf8)
            }

            // 7. 复制到 App Group shared 目录
            try installRimeIceFiles(from: extractDir)

            // 8. 清理临时文件
            try? fm.removeItem(at: extractDir)
            try? fm.removeItem(at: tempURL)

            // 9. 更新版本和 schema
            let version = extractVersionFrom(files: extractedFiles) ?? "unknown"
            rimeIceVersion = version
            defaults.set(version, forKey: "rime_ice_version")
            defaults.set(true, forKey: "rime_ice_installed")

            // 10. 先激活 schema（设置 active + requestDeploy），再执行全量部署
            activateRimeIce()

            // 11. 主 App 端全量部署（编译 YAML → .bin，覆盖 requestDeploy 标记）
            rimeIceDownloadState = .deploying
            await deployRimeConfig()

            rimeIceDownloadState = .completed
            refreshSchemaList()

        } catch let error as DownloadError {
            rimeIceDownloadState = .failed(error.localizedDescription)
        } catch {
            rimeIceDownloadState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Download helpers

    private func fetchLatestReleaseURL() async throws -> URL? {
        let apiURL = URL(string: "https://api.github.com/repos/iDvel/rime-ice/releases/latest")!
        var request = URLRequest(url: apiURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("UniverseKeyboard/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DownloadError.networkError("无效的 HTTP 响应")
        }
        if httpResponse.statusCode == 403 {
            throw DownloadError.gitHubRateLimit
        }
        guard httpResponse.statusCode == 200 else {
            throw DownloadError.networkError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let assets = json["assets"] as? [[String: Any]],
              let fullZip = assets.first(where: { ($0["name"] as? String) == "full.zip" }),
              let downloadURLStr = fullZip["browser_download_url"] as? String,
              let url = URL(string: downloadURLStr) else {
            return nil
        }
        return url
    }

    private func downloadZip(from url: URL) async throws -> (URL, URLResponse) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 300
        let hasEtag = defaults.string(forKey: "rime_ice_etag")
        if let etag = hasEtag, !etag.isEmpty {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

        let (tempURL, response) = try await URLSession.shared.download(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DownloadError.networkError("无效的 HTTP 响应")
        }

        if httpResponse.statusCode == 304 {
            let localURL = fm.temporaryDirectory.appendingPathComponent("rime_ice_full.zip")
            if fm.fileExists(atPath: localURL.path) {
                return (localURL, response)
            }
            // ETag 缓存命中但临时文件已被清除：清除 ETag 后重试
            defaults.removeObject(forKey: "rime_ice_etag")
            return try await downloadZip(from: url)
        }

        guard httpResponse.statusCode == 200 else {
            throw DownloadError.networkError("下载失败，HTTP \(httpResponse.statusCode)")
        }

        // 处理 chunked transfer encoding（expectedContentLength = -1）
        let expectedSize = response.expectedContentLength
        guard expectedSize > 0 || expectedSize == -1 else {
            throw DownloadError.networkError("服务器未提供文件大小")
        }

        if let etag = httpResponse.allHeaderFields["Etag"] as? String {
            defaults.set(etag, forKey: "rime_ice_etag")
        }

        let localURL = fm.temporaryDirectory.appendingPathComponent("rime_ice_full.zip")
        try? fm.removeItem(at: localURL)
        try fm.moveItem(at: tempURL, to: localURL)
        return (localURL, response)
    }

    private func findFile(named name: String, in dir: URL) -> URL? {
        guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: nil) else { return nil }
        for case let url as URL in enumerator {
            if url.lastPathComponent == name { return url }
        }
        return nil
    }

    private func extractVersionFrom(files: [String]) -> String? {
        return rimeIceVersion ?? "latest"
    }

    private func installRimeIceFiles(from extractDir: URL) throws {
        guard let containerURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { throw DownloadError.networkError("App Group 不可用") }

        let sharedDir = containerURL.appendingPathComponent("Rime/shared")
        try? fm.createDirectory(at: sharedDir, withIntermediateDirectories: true)

        guard let enumerator = fm.enumerator(at: extractDir, includingPropertiesForKeys: nil) else {
            throw DownloadError.extractionFailed("无法遍历解压目录")
        }

        for case let fileURL as URL in enumerator {
            guard !fileURL.hasDirectoryPath else { continue }

            let relativePath = fileURL.path.replacingOccurrences(of: extractDir.path + "/", with: "")
            let destURL = sharedDir.appendingPathComponent(relativePath)

            // 跳过桌面前端配置（lua/ 目录保留 — Lua 模块可用时需要）
            // object(forKey:) 区分 nil（首次，默认 Lua 可用）和明确 false
            let luaAvailable = (UserDefaults(suiteName: appGroupID)?.object(forKey: "rime_lua_available") as? Bool) ?? true
            let skipPrefixes = ["squirrel", "weasel", "recipe", "others/"] + (luaAvailable ? [] : ["lua/"])
            let skipFiles = ["radical_pinyin.schema.yaml", "radical_pinyin.dict.yaml"]
            let fileName = fileURL.lastPathComponent

            if skipFiles.contains(fileName) || skipPrefixes.contains(where: { relativePath.hasPrefix($0) }) {
                continue
            }

            try? fm.createDirectory(at: destURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            if fm.fileExists(atPath: destURL.path) {
                try? fm.removeItem(at: destURL)
            }
            try fm.copyItem(at: fileURL, to: destURL)
        }
    }

    private func activateRimeIce() {
        defaults.set("rime_ice", forKey: "rime_active_schema")
        activeSchemaID = "rime_ice"
        requestDeploy()
    }

    // MARK: - Uninstall

    func uninstallRimeIce() {
        guard let containerURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

        let sharedDir = containerURL.appendingPathComponent("Rime/shared")

        // 删除 rime_ice 相关文件
        let rimeIceFiles = [
            "rime_ice.schema.yaml", "rime_ice.dict.yaml",
            "melt_eng.schema.yaml", "melt_eng.dict.yaml",
            "symbols_v.yaml", "symbols_caps_v.yaml",
            "custom_phrase.txt"
        ]
        for f in rimeIceFiles {
            try? fm.removeItem(at: sharedDir.appendingPathComponent(f))
        }

        // 删除子目录
        for subdir in ["cn_dicts", "en_dicts"] {
            try? fm.removeItem(at: sharedDir.appendingPathComponent(subdir))
        }

        // 删除 rime_ice 编译产物
        let buildDir = sharedDir.appendingPathComponent("build")
        if let files = try? fm.contentsOfDirectory(atPath: buildDir.path) {
            for f in files where f.contains("rime_ice") || f.contains("melt_eng") {
                try? fm.removeItem(at: buildDir.appendingPathComponent(f))
            }
        }

        // 清除状态
        for key in ["rime_ice_installed", "rime_ice_version", "rime_ice_license_accepted",
                     "rime_ice_download_url", "rime_ice_etag", "rime_ice_checksum"] {
            defaults.removeObject(forKey: key)
        }

        switchToSchema("luna_pinyin")
        rimeIceDownloadState = .idle
        rimeIceLicenseAccepted = false
        rimeIceVersion = nil
        refreshSchemaList()
    }

    // MARK: - Check for updates

    func checkForUpdate() async -> Bool {
        do {
            guard let url = try await fetchLatestReleaseURL() else { return false }
            let newVersion = url.lastPathComponent
            return newVersion != rimeIceVersion
        } catch {
            return false
        }
    }

    // MARK: - Helpers

    private func rimeIceFilesExist() -> Bool {
        guard let containerURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return false }
        let sharedDir = containerURL.appendingPathComponent("Rime/shared")
        let schema = sharedDir.appendingPathComponent("rime_ice.schema.yaml")
        return fm.fileExists(atPath: schema.path)
    }

    private func checkDiskSpace(needed: Int64) throws {
        guard let containerURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }
        let values = try containerURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        let available = Int64(values.volumeAvailableCapacity ?? 0)
        guard available >= needed else {
            throw DownloadError.diskSpaceInsufficient(needed: needed, available: available)
        }
    }

    private func requestDeploy() {
        defaults.set(false, forKey: "rime_deployed")
        defaults.set(true, forKey: "rime_needs_deploy")
        defaults.synchronize()
    }

    /// 在主 App 端执行全量 RIME 部署（编译 YAML → .bin）。
    /// 部署在后台线程执行，避免阻塞 UI。
    private func deployRimeConfig() async {
        guard let containerURL = fm.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            Logger.shared.error("deployRimeConfig: App Group 不可用", category: .deployment)
            return
        }

        let sharedDir = containerURL.appendingPathComponent("Rime/shared").path
        let userDir = containerURL.appendingPathComponent("Rime/user").path

        try? fm.createDirectory(atPath: userDir, withIntermediateDirectories: true)

        Logger.shared.info("deployRimeConfig: 开始主 App 端全量部署", category: .deployment)

        defaults.set(true, forKey: "rime_deploying")
        defaults.set(false, forKey: "rime_deployed")
        defaults.synchronize()

        await Task.detached {
            let deployer = RimeDeployer()
            Logger.shared.info("deployRimeConfig: librime version \(deployer.librimeVersion())", category: .deployment)
            let success = deployer.deploy(withSharedDataDir: sharedDir, userDataDir: userDir)
            let defaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard")
            if success {
                Logger.shared.info("deployRimeConfig: 部署成功 ✓", category: .deployment)
                defaults?.set(true, forKey: "rime_deployed")
                defaults?.set(false, forKey: "rime_needs_deploy")
                defaults?.set(false, forKey: "rime_deploying")
            } else {
                Logger.shared.error("deployRimeConfig: 部署失败 ✗（键盘扩展将兜底部署）", category: .deployment)
                defaults?.set(false, forKey: "rime_deployed")
                defaults?.set(true, forKey: "rime_needs_deploy")
                defaults?.set(false, forKey: "rime_deploying")
            }
            defaults?.synchronize()
        }.value
    }

}

// MARK: - Download errors

enum DownloadError: Error, LocalizedError {
    case networkError(String)
    case gitHubRateLimit
    case diskSpaceInsufficient(needed: Int64, available: Int64)
    case corruptArchive
    case extractionFailed(String)
    case postProcessingFailed(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "网络错误：\(msg)"
        case .gitHubRateLimit: return "GitHub API 限流，请稍后再试（约 1 小时后重置）"
        case .diskSpaceInsufficient(let needed, let available):
            let needMB = needed / 1_000_000
            let availMB = available / 1_000_000
            return "存储空间不足（需要约 \(needMB) MB，可用 \(availMB) MB）"
        case .corruptArchive: return "下载文件损坏，请重试"
        case .extractionFailed(let msg): return "解压失败：\(msg)"
        case .postProcessingFailed(let msg): return "配置文件处理失败：\(msg)"
        }
    }
}
