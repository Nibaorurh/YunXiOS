import SwiftUI
import UIKit

/// 平台卡片：40pt 图标 + 名称 + 登录状态 + 登录/管理按钮
struct PlatformCard: View {
    @EnvironmentObject private var theme: ThemeManager
    let platform: CloudPlatform
    let account: PlatformAccount?
    let onLogin: () -> Void
    let onManage: () -> Void

    private var tint: Color { Color(hex: UInt(platform.tint, radix: 16) ?? 0x0B57D0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                platformIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(platform.name)
                        .font(.subheadline).fontWeight(.semibold)
                        .lineLimit(1)
                    statusText
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            Button(action: account?.isLoggedIn == true ? onManage : onLogin) {
                Text(account?.isLoggedIn == true ? "管理" : "登录")
                    .font(.caption).fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(account?.isLoggedIn == true ? tint.opacity(0.15) : theme.primary, in: Capsule())
                    .foregroundStyle(account?.isLoggedIn == true ? tint : .white)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var platformIcon: some View {
        Group {
            if let name = platform.logoName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: platform.symbol)
                    .resizable()
                    .scaledToFit()
                    .padding(6)
                    .foregroundStyle(tint)
            }
        }
        .frame(width: 40, height: 40)
    }
    @ViewBuilder
    private var statusText: some View {
        if let account, account.isLoggedIn {
            Text("已登录：\(account.nickname ?? "")")
                .foregroundStyle(tint)
        } else if platform.loginRequired {
            Text("未登录")
        } else {
            Text("无需登录，直接解析")
                .foregroundStyle(.green)
        }
    }
}

/// 通用分组卡片容器
struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ScrollView {
        SectionCard(title: "网盘账号", systemImage: "square.stack.3d.up") {
            PlatformCard(platform: CloudPlatform.clouds[0], account: nil, onLogin: {}, onManage: {})
        }
        .padding()
    }
    .environmentObject(ThemeManager())
}
