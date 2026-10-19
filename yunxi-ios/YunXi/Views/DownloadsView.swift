import SwiftUI
import UIKit

/// 下载页：任务列表 + 统计 + FAB 手动添加
struct DownloadsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: AppStore
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 统计行
                        statsRow

                        // 批量操作
                        if !store.tasks.isEmpty {
                            HStack(spacing: 12) {
                                Button("全部开始") { store.resumeAll() }
                                    .buttonStyle(.bordered)
                                    .tint(theme.primary)
                                Button("全部暂停") { store.pauseAll() }
                                    .buttonStyle(.bordered)
                                Spacer()
                                Button("删除全部", role: .destructive) { store.removeAll() }
                                    .buttonStyle(.bordered)
                            }
                        }

                        // 任务列表
                        if store.tasks.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 12) {
                                ForEach(store.tasks) { task in
                                    taskCard(task)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 96)
                }

                // FAB
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                        .font(.title2).fontWeight(.semibold)
                        .frame(width: 56, height: 56)
                        .background(theme.primary, in: Circle())
                        .foregroundStyle(.white)
                        .shadow(color: theme.primary.opacity(0.4), radius: 10, y: 4)
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("下载")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image("AppLogo").resizable().frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text("下载").font(.headline)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addSheet
        }
    }

    // MARK: 统计

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCell(value: "\(store.downloadingCount)", label: "进行中")
            statCell(value: "\(store.finishedCount)", label: "已完成")
            statCell(value: DownloadTask.format(store.totalSpeed) + "/s", label: "总速度")
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title3).fontWeight(.bold).foregroundStyle(theme.primary)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: 空态

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(.tertiary)
            Text("暂无下载任务")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: 任务卡片

    private func taskCard(_ task: DownloadTask) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundStyle(theme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.fileName).font(.subheadline).fontWeight(.medium).lineLimit(1)
                    Text(task.platformName).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                Text(task.state.rawValue)
                    .font(.caption2).fontWeight(.medium)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(theme.primary.opacity(0.12), in: Capsule())
                    .foregroundStyle(theme.primary)
            }

            ProgressView(value: task.progress)
                .tint(theme.primary)

            HStack {
                Text(task.progressText).font(.caption2).foregroundStyle(.secondary)
                Spacer()
                if task.state == .downloading {
                    Text(DownloadTask.format(task.speedBytesPerSec) + "/s")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button(task.state == .paused ? "开始" : "暂停") {
                    // 演示：切换状态
                }
                .buttonStyle(.bordered).tint(theme.primary)
                Spacer()
                Button("删除", role: .destructive) { }
                    .buttonStyle(.bordered)
            }
            .font(.caption)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: 手动添加 sheet

    private var addSheet: some View {
        NavigationStack {
            Form {
                Section("演示任务") {
                    Button("添加示例任务") {
                        store.addTask(fileName: "云析.app 功能介绍.mp4",
                                      platformName: "百度网盘",
                                      totalBytes: 134_479_872)
                        showAddSheet = false
                    }
                }
            }
            .navigationTitle("手动添加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { showAddSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    DownloadsView()
        .environmentObject(ThemeManager())
        .environmentObject(AppStore())
}
