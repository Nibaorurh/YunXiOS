import Foundation
import SwiftUI

/// 全局状态（账号 + 下载任务 + 设置项）
final class AppStore: ObservableObject {
    // 账号
    @Published var accounts: [PlatformAccount] = CloudPlatform.clouds.map { PlatformAccount(platform: $0) }
        + CloudPlatform.videos.map { PlatformAccount(platform: $0) }

    // 下载
    @Published var tasks: [DownloadTask] = []

    // 设置项（对应原应用设置页）
    @AppStorage("threads") var threads: Int = 16
    @AppStorage("chunkMB") var chunkMB: Int = 4
    @AppStorage("saveDir") var saveDir: String = "/Download/云析"
    @AppStorage("keepBackground") var keepBackground: Bool = true
    @AppStorage("notifyProgress") var notifyProgress: Bool = true
    @AppStorage("internalEngine") var internalEngine: Bool = true

    func login(_ platform: CloudPlatform, nickname: String) {
        if let i = accounts.firstIndex(where: { $0.platform.id == platform.id }) {
            accounts[i].nickname = nickname
        }
    }

    func logout(_ platform: CloudPlatform) {
        if let i = accounts.firstIndex(where: { $0.platform.id == platform.id }) {
            accounts[i].nickname = nil
        }
    }

    func account(for platform: CloudPlatform) -> PlatformAccount? {
        accounts.first { $0.platform.id == platform.id }
    }

    // MARK: 下载任务操作

    func addTask(fileName: String, platformName: String, totalBytes: Int64) {
        tasks.insert(DownloadTask(fileName: fileName,
                                  platformName: platformName,
                                  totalBytes: totalBytes,
                                  receivedBytes: 0,
                                  state: .downloading,
                                  speedBytesPerSec: 1_600_000), at: 0)
    }

    func pauseAll() {
        for i in tasks.indices where tasks[i].state == .downloading {
            tasks[i].state = .paused
        }
    }

    func resumeAll() {
        for i in tasks.indices where tasks[i].state == .paused {
            tasks[i].state = .downloading
        }
    }
    func removeAll() { tasks.removeAll() }

    var downloadingCount: Int { tasks.filter { $0.state == .downloading }.count }
    var finishedCount: Int { tasks.filter { $0.state == .finished }.count }
    var totalSpeed: Int64 { tasks.filter { $0.state == .downloading }.reduce(0) { $0 + $1.speedBytesPerSec } }
}
