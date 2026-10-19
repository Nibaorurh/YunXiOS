import SwiftUI

/// 主框架：底部 4 Tab（解析 / 账号 / 下载 / 设置），对应原应用信息架构
struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @State private var selectedTab: Tab = .resolve

    enum Tab: String, CaseIterable {
        case resolve = "解析"
        case drive = "账号"
        case download = "下载"
        case settings = "设置"

        var icon: String {
            switch self {
            case .resolve:   return "link"
            case .drive:     return "person.crop.circle"
            case .download:  return "arrow.down.circle"
            case .settings:  return "gearshape"
            }
        }
        var iconFilled: String {
            switch self {
            case .resolve:   return "link.circle.fill"
            case .drive:     return "person.crop.circle.fill"
            case .download:  return "arrow.down.circle.fill"
            case .settings:  return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ParseView()
                .tabItem { Label(Tab.resolve.rawValue, systemImage: selectedTab == .resolve ? Tab.resolve.iconFilled : Tab.resolve.icon) }
                .tag(Tab.resolve)

            AccountsView()
                .tabItem { Label(Tab.drive.rawValue, systemImage: selectedTab == .drive ? Tab.drive.iconFilled : Tab.drive.icon) }
                .tag(Tab.drive)

            DownloadsView()
                .tabItem { Label(Tab.download.rawValue, systemImage: selectedTab == .download ? Tab.download.iconFilled : Tab.download.icon) }
                .tag(Tab.download)

            SettingsView()
                .tabItem { Label(Tab.settings.rawValue, systemImage: selectedTab == .settings ? Tab.settings.iconFilled : Tab.settings.icon) }
                .tag(Tab.settings)
        }
        .tint(theme.primary)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(AppStore())
}
