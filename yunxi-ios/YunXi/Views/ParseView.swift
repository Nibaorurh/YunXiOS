import SwiftUI
import UIKit

/// 解析页：粘贴分享链接 → 一键解析
struct ParseView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var store: AppStore
    @State private var link: String = ""
    @State private var code: String = ""
    @State private var showCodeField = false
    @State private var isParsing = false
    @State private var parsedFiles: [ParsedFile] = []
    @State private var showResult = false
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 公告横幅
                    banner

                    // 解析卡片
                    parseCard

                    // 解析结果
                    if showResult {
                        resultCard
                    }

                    // 能力 chips
                    chips

                    // 免责声明
                    Text("本应用仅供个人学习与技术交流使用，版权归原作者所有\n开源地址 github.com/CYQawa/YunX")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("云析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        Text("云析").font(.headline)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Text("v1.3.0").font(.caption2).foregroundStyle(.secondary)
                        Button { toast = "暂无新公告" } label: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(theme.primary)
                        }
                    }
                }
            }
        }
        .alert("提示", isPresented: .constant(toast != nil), actions: {
            Button("知道了") { toast = nil }
        }, message: {
            Text(toast ?? "")
        })
    }

    // MARK: 公告横幅

    private var banner: some View {
        HStack(spacing: 10) {
            Image(systemName: "megaphone.fill")
                .foregroundStyle(.white)
                .padding(6)
                .background(theme.primary, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("有新公告时会在这里显示 · 点击查看")
                    .font(.subheadline).fontWeight(.medium)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "xmark").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(theme.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: 解析卡片

    private var parseCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("粘贴分享链接，一键解析分享内容")
                .font(.title3).fontWeight(.bold)

            // 分享链接输入
            VStack(alignment: .leading, spacing: 6) {
                Text("分享链接").font(.caption).foregroundStyle(theme.primary).fontWeight(.medium)
                TextField("请输入网盘链接，自动识别剪贴板", text: $link, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                    .padding(10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            }

            // 按钮行
            HStack(spacing: 12) {
                Button {
                    link = UIPasteboard.general.string ?? ""
                    if link.isEmpty { toast = "剪贴板为空" }
                } label: {
                    Text("粘贴").font(.subheadline).fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(theme.primary.opacity(0.12), in: Capsule())
                        .foregroundStyle(theme.primary)
                }
                Button { link = ""; parsedFiles = []; showResult = false } label: {
                    Text("清空").font(.subheadline).fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .foregroundStyle(.secondary)
                }
                Button { startParse() } label: {
                    Text(isParsing ? "解析中…" : "开始解析")
                        .font(.subheadline).fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(theme.primary, in: Capsule())
                        .foregroundStyle(.white)
                }
                .disabled(link.trimmingCharacters(in: .whitespaces).isEmpty || isParsing)
                .opacity(link.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }

            // 提取码
            if showCodeField {
                HStack {
                    Text("提取码").font(.caption).foregroundStyle(.secondary)
                    TextField("请输入提取码", text: $code)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 140)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Text("该分享需要提取码时，解析后会自动弹出输出框")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: 解析结果卡片

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("解析完成", systemImage: "checkmark.seal.fill")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(theme.primary)
                Spacer()
                Button { showResult = false } label: {
                    Image(systemName: "xmark").font(.caption).foregroundStyle(.secondary)
                }
            }
            ForEach(parsedFiles) { file in
                HStack {
                    Image(systemName: file.isDir ? "folder.fill" : "doc.fill")
                        .foregroundStyle(theme.primary)
                    Text(file.name).font(.subheadline).lineLimit(1)
                    Spacer()
                    Text(DownloadTask.format(file.size)).font(.caption).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: 能力 chips

    private let capabilities = ["10 大网盘", "7 大视频平台", "分片下载", "完全免费"]

    private var chips: some View {
        FlowLayout(spacing: 8) {
            ForEach(capabilities, id: \.self) { item in
                Text(item)
                    .font(.caption).fontWeight(.medium)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .background(theme.primary.opacity(0.10), in: Capsule())
                    .foregroundStyle(theme.primary)
            }
        }
    }

    // MARK: 解析逻辑（演示数据，与原应用行为一致）

    private func startParse() {
        isParsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isParsing = false
            parsedFiles = [
                ParsedFile(name: "云析.app 功能介绍.mp4", size: 134_479_872),
                ParsedFile(name: "使用手册.pdf", size: 2_097_152),
                ParsedFile(name: "素材文件夹", size: 0, isDir: true)
            ]
            showResult = true
            showCodeField = Bool.random()
        }
    }
}

/// 简易流式布局（chips 换行）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
    }
}

#Preview {
    ParseView()
        .environmentObject(ThemeManager())
        .environmentObject(AppStore())
}
