import SwiftUI
import UIKit

/// 设置页：外观 / 主题色 / 下载参数 / 关于
struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    appearanceCard
                    downloadCard
                    aboutCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image("AppLogo").resizable().frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text("设置").font(.headline)
                    }
                }
            }
        }
    }

    // MARK: 外观

    private var appearanceCard: some View {
        SectionCard(title: "外观", systemImage: "paintpalette") {
            VStack(alignment: .leading, spacing: 14) {
                // 外观模式
                VStack(alignment: .leading, spacing: 8) {
                    Label("外观模式", systemImage: "circle.lefthalf.filled")
                    Text("选择应用的明暗外观").font(.caption2).foregroundStyle(.secondary)
                    Picker("外观模式", selection: $theme.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                // 主题色
                VStack(alignment: .leading, spacing: 8) {
                    Label("主题色", systemImage: "paintbrush.fill")
                    Text("当前：\(theme.themeColor.rawValue)").font(.caption2).foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ThemeColor.allCases) { item in
                                Button { theme.themeColor = item } label: {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(item.primary)
                                            .frame(width: 34, height: 34)
                                            .overlay {
                                                if theme.themeColor == item {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption).fontWeight(.bold)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                        Text(item.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(theme.themeColor == item ? .primary : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Divider()

                // 桌面图标
                HStack {
                    Label("桌面图标", systemImage: "apps.iphone")
                    Spacer()
                    Text("经典图标").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: 下载设置

    private var downloadCard: some View {
        SectionCard(title: "下载", systemImage: "arrow.down.circle") {
            VStack(alignment: .leading, spacing: 16) {
                // 下载引擎
                HStack {
                    Label("下载引擎", systemImage: "music.note")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("下载引擎决定新任务由谁来执行")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("内置分片下载器").font(.caption).foregroundStyle(theme.primary)
                }

                Divider()

                // 下载线程数
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("下载线程数", systemImage: "square.stack.3d.up")
                        Spacer()
                        Text("\(store.threads)").foregroundStyle(.secondary)
                    }
                    Slider(value: Binding(get: { Double(store.threads) },
                                          set: { store.threads = Int($0) }),
                           in: 8...32, step: 1)
                        .tint(theme.primary)
                    Text("线程数不是越多越好，建议 8~32").font(.caption2).foregroundStyle(.secondary)
                }

                Divider()

                // 分片大小
                HStack {
                    Label("分片大小", systemImage: "square.grid.2x2")
                    Spacer()
                    Stepper("\(store.chunkMB) MB", value: $store.chunkMB, in: 1...16, step: 1)
                        .fixedSize()
                }

                Divider()

                // 保存目录
                HStack {
                    Label("下载保存目录", systemImage: "folder")
                    Spacer()
                    Text(store.saveDir).font(.caption).foregroundStyle(.secondary)
                }

                Divider()

                // 保持后台下载
                Toggle(isOn: $store.keepBackground) {
                    Label("保持后台下载", systemImage: "lock")
                    Text("锁屏或切到后台下载不会被系统冻结")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                .tint(theme.primary)

                Divider()

                // 通知栏进度
                Toggle(isOn: $store.notifyProgress) {
                    Label("通知栏下载进度", systemImage: "bell")
                    Text("完成提醒显示在通知栏")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                .tint(theme.primary)
            }
        }
    }

    // MARK: 关于

    private var aboutCard: some View {
        SectionCard(title: "关于", systemImage: "info.circle") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image("AppLogo").resizable().frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("云析").font(.headline)
                        Text("版本 1.3.0 (14)").font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                Text("网盘/视频链接解析与高速下载工具")
                    .font(.caption).foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    capabilityChip("10 大网盘")
                    capabilityChip("7 大视频平台")
                    capabilityChip("分片下载")
                    capabilityChip("完全免费")
                }

                Text("本应用仅供个人学习与技术交流使用，版权归原作者所有\n开源地址 github.com/CYQawa/YunX")
                    .font(.caption2).foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
    }

    private func capabilityChip(_ text: String) -> some View {
        Text(text)
            .font(.caption2).fontWeight(.medium)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(theme.primary.opacity(0.10), in: Capsule())
            .foregroundStyle(theme.primary)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(AppStore())
}
