import SwiftUI
import UIKit

/// 账号页：10 大网盘 + 7 大视频平台登录管理
struct AccountsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: AppStore
    @State private var loginPlatform: CloudPlatform?
    @State private var loginNickname: String = ""

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionCard(title: "网盘账号", systemImage: "square.stack.3d.up") {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(CloudPlatform.clouds) { platform in
                                PlatformCard(platform: platform,
                                             account: store.account(for: platform),
                                             onLogin: { loginPlatform = platform },
                                             onManage: { showManage(platform) })
                            }
                        }
                    }

                    SectionCard(title: "视频平台", systemImage: "play.rectangle") {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(CloudPlatform.videos) { platform in
                                PlatformCard(platform: platform,
                                             account: store.account(for: platform),
                                             onLogin: { loginPlatform = platform },
                                             onManage: { showManage(platform) })
                            }
                        }
                    }

                    Text("登录后可解析更高清晰度")
                        .font(.caption2).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("账号")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image("AppLogo").resizable().frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text("账号").font(.headline)
                    }
                }
            }
        }
        .sheet(item: $loginPlatform) { platform in
            loginSheet(platform)
        }
    }

    // MARK: 登录 WebView 模拟 sheet

    private func loginSheet(_ platform: CloudPlatform) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                Group {
                    if let name = platform.logoName, UIImage(named: name) != nil {
                        Image(name).resizable().scaledToFit()
                    } else {
                        Image(systemName: platform.symbol)
                            .resizable().scaledToFit()
                            .foregroundStyle(Color(hex: UInt(platform.tint, radix: 16) ?? 0x0B57D0))
                    }
                }
                .frame(width: 64, height: 64)
                Text("登录 \(platform.name)")
                    .font(.title3).fontWeight(.bold)
                Text("将打开 \(platform.name) 官方登录页\n登录成功后返回本应用即可")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                TextField("昵称（演示）", text: $loginNickname)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)
                Button {
                    store.login(platform, nickname: loginNickname.isEmpty ? "云析用户" : loginNickname)
                    loginNickname = ""
                    loginPlatform = nil
                } label: {
                    Text("确认登录")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(theme.primary, in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
            .padding(.top, 40)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { loginPlatform = nil }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func showManage(_ platform: CloudPlatform) {
        store.logout(platform)
    }
}

#Preview {
    AccountsView()
        .environmentObject(ThemeManager())
        .environmentObject(AppStore())
}
