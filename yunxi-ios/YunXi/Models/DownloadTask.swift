import Foundation

/// 下载任务状态
enum DownloadState: String {
    case waiting = "等待中"
    case downloading = "下载中"
    case paused = "已暂停"
    case finished = "已完成"
    case failed = "失败"
}

/// 下载任务（对应原应用下载页）
struct DownloadTask: Identifiable, Equatable {
    let id = UUID()
    var fileName: String
    var platformName: String
    var totalBytes: Int64
    var receivedBytes: Int64
    var state: DownloadState
    var speedBytesPerSec: Int64 = 0

    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return min(1.0, Double(receivedBytes) / Double(totalBytes))
    }

    var progressText: String {
        "已下载 \(Self.format(receivedBytes)) / \(Self.format(totalBytes)) · \(Int(progress * 100))%"
    }

    static func format(_ bytes: Int64) -> String {
        let kb = 1024.0, mb = kb * 1024, gb = mb * 1024
        let b = Double(bytes)
        switch b {
        case ..<kb: return String(format: "%.0f B", b)
        case ..<mb: return String(format: "%.1f KB", b / kb)
        case ..<gb: return String(format: "%.1f MB", b / mb)
        default:    return String(format: "%.2f GB", b / gb)
        }
    }
}

/// 解析结果文件
struct ParsedFile: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var size: Int64
    var isDir: Bool = false
}
