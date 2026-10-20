import Foundation

/// 平台类型
enum PlatformKind: String, CaseIterable, Identifiable {
    case cloud = "网盘"
    case video = "视频"
    var id: String { rawValue }
}

/// 云盘 / 视频平台模型（对应原应用 10 大网盘 + 7 大视频平台）
struct CloudPlatform: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let kind: PlatformKind
    /// Assets.xcassets/Platforms 中的图标名
    let logoName: String?
    /// SF Symbol 备用图标
    let symbol: String
    /// 是否需要登录才能解析
    var loginRequired: Bool = true
    /// 主题色
    var tint: String = "0B57D0"

    static let clouds: [CloudPlatform] = [
        CloudPlatform(name: "百度网盘",     kind: .cloud, logoName: "baidu",    symbol: "cloud.fill",       tint: "2932E1"),
        CloudPlatform(name: "迅雷",         kind: .cloud, logoName: "xunlei",   symbol: "bolt.fill",        tint: "0077ED"),
        CloudPlatform(name: "夸克",         kind: .cloud, logoName: "quark",    symbol: "magnifyingglass",  tint: "F0884B"),
        CloudPlatform(name: "UC网盘",       kind: .cloud, logoName: "uc",       symbol: "globe",            tint: "FF6A00"),
        CloudPlatform(name: "115",          kind: .cloud, logoName: "pan115",   symbol: "number",           tint: "E8590C"),
        CloudPlatform(name: "123盘",        kind: .cloud, logoName: "123pan",   symbol: "externaldrive.fill", tint: "3B7DD8"),
        CloudPlatform(name: "蓝奏云",       kind: .cloud, logoName: "lanzou",   symbol: "folder.fill",      tint: "2F80ED"),
        CloudPlatform(name: "蓝奏云优享版", kind: .cloud, logoName: "ilanzou",  symbol: "star.fill",        tint: "1D6FD9"),
        CloudPlatform(name: "和彩云",       kind: .cloud, logoName: "c139",     symbol: "envelope.fill",    tint: "E60012"),
        CloudPlatform(name: "光鸭云盘",     kind: .cloud, logoName: "guangya",  symbol: "duck.fill",        tint: "0FA3A3")
    ]

    static let videos: [CloudPlatform] = [
        CloudPlatform(name: "哔哩哔哩", kind: .video, logoName: "bilibili", symbol: "tv.fill",            loginRequired: true,  tint: "FB7299"),
        CloudPlatform(name: "抖音",      kind: .video, logoName: "douyin",   symbol: "music.note",        loginRequired: false, tint: "000000"),
        CloudPlatform(name: "微博",      kind: .video, logoName: "weibo",    symbol: "bubble.left.fill",  loginRequired: false, tint: "E6162D"),
        CloudPlatform(name: "快手",      kind: .video, logoName: "kuaishou", symbol: "play.fill",         loginRequired: false, tint: "FF4906"),
        CloudPlatform(name: "AcFun",     kind: .video, logoName: "acfun",    symbol: "a.circle.fill",     loginRequired: false, tint: "FD4C43"),
        CloudPlatform(name: "小红书",    kind: .video, logoName: "xhs",      symbol: "book.fill",         loginRequired: false, tint: "FF2442"),
        CloudPlatform(name: "Pixiv",     kind: .video, logoName: "pixiv",    symbol: "paintpalette.fill", loginRequired: false, tint: "0096FA")
    ]
}

/// 账号登录状态
struct PlatformAccount: Identifiable, Equatable {
    let id = UUID()
    var platform: CloudPlatform
    var nickname: String?
    var isLoggedIn: Bool { nickname != nil && !(nickname?.isEmpty ?? true) }
}
