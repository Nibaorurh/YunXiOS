# 云析 iOS 复刻版（YunXi for iOS）

从 Android 应用「云析 v1.3.0」（com.yunx.app，开源项目 CYQawa/YunX）逆向还原的
SwiftUI 原生复刻工程。界面信息架构、主题系统、平台数据均按原应用还原。

- 部署目标：**iOS 16.2+**（在 iPhone 14 Pro Max / iOS 16.6 巨魔上验证安装路径）
- UI 框架：SwiftUI + Material3 风格视觉（原应用为 Jetpack Compose + Material3）
- 无第三方依赖，纯系统框架

## 目录结构

```
yunxi-ios/
├── project.yml                  # XcodeGen 配置（推荐入口）
├── YunXi/
│   ├── YunXiApp.swift           # @main 入口 + 全局状态注入
│   ├── ContentView.swift        # 底部 4 Tab 主框架（解析/账号/下载/设置）
│   ├── Models/
│   │   ├── CloudPlatform.swift  # 10 大网盘 + 7 大视频平台数据
│   │   ├── DownloadTask.swift   # 下载任务/解析文件模型
│   │   └── AppStore.swift       # 全局 ObservableObject（账号/下载/设置）
│   ├── Theme/
│   │   └── ThemeManager.swift   # 10 套主题色 + 浅色/深色/跟随系统
│   ├── Views/
│   │   ├── ParseView.swift      # 解析页（链接输入/粘贴/解析/chips）
│   │   ├── AccountsView.swift   # 账号页（平台卡片网格/登录 sheet）
│   │   ├── DownloadsView.swift  # 下载页（统计/任务进度/FAB）
│   │   ├── SettingsView.swift   # 设置页（外观/主题色/下载参数/关于）
│   │   └── Components/
│   │       └── PlatformCard.swift  # 平台卡片 + SectionCard + FlowLayout
│   └── Resources/
│       ├── Assets.xcassets/     # AppIcon 1024 + 18 个平台 logo（从 APK 提取）
│       ├── Info.plist
│       └── YunXi.entitlements
└── prep_ios_assets.py           # 资产生成脚本（已执行，无需重跑）
```

---

---

## 方式 0：GitHub Actions 云编译（没有 Mac，约 10 分钟拿 IPA）★推荐

仓库已内置 `.github/workflows/build-ipa.yml`，推送到 GitHub 后自动在 macOS  runner 上
编译并产出**未签名 IPA**（巨魔不校验签名，可直接装）。

1. 打开 <https://github.com/new>，仓库名填 `yunxi-ios`，选 **Private**，Create repository
   （**不要**勾选 "Add a README"）
2. 在仓库页点 **Add file → Upload files**，把本文件夹（`yunxi-ios/`，含隐藏的 `.github`）整个拖进去
   → Commit changes
   - 若拖拽丢了隐藏的 `.github` 目录，改用 GitHub Desktop（免费）：Add Local Repository 选本文件夹 → Publish
3. 点仓库顶部 **Actions** → 首次会提示 "I understand my workflows..."，点绿色按钮启用
   → `Build IPA` 工作流会自动开始跑（没跑就进 Workflow 页右上角 **Run workflow**）
4. 等约 5–10 分钟变绿 → 页面底部 **Artifacts** 下载 `YunXi-ipa` → 解压得到 **`YunXi.ipa`**
5. AirDrop/文件传到 iPhone → **巨魔（TrollStore）打开 IPA 安装** → 桌面出现「云析」

> 免费额度：私有库每月 2000 分钟（macOS runner 按 10 倍消耗，一次构建约几百，够用）；
> 想更省就把仓库设 Public。每次 push 到 main 都会重新构建。

## 方式 A：XcodeGen 一键生成工程（有 Mac）

```bash
# 1. 安装 XcodeGen（只需一次）
brew install xcodegen

# 2. 进入工程目录生成 .xcodeproj
cd yunxi-ios
xcodegen generate

# 3. 用 Xcode 打开
open YunXi.xcodeproj
```

然后在 Xcode 中：

1. 选中 YunXi target → **Signing & Capabilities**
   - 勾选 **Automatically manage signing**
   - Team 选你的 Apple ID（个人免费账号即可；巨魔安装不校验签名）
   - Bundle Identifier 如与已有项目冲突，改成 `com.yunx.app.yourname`
2. 目标设备选 **Any iOS Device (arm64)** 或你的 iPhone
3. **Product → Archive**（或直接 ⌘R 运行到真机）

## 方式 B：Xcode 手动建工程（不想装 XcodeGen）

1. Xcode → **File → New → Project → iOS → App**
   - Product Name: `YunXi`，Interface: **SwiftUI**，Language: **Swift**
   - Team 选 Apple ID，Organization Identifier 随意（如 `com.yunx`）
   - 最低部署版本选 **iOS 16.2**
2. 删除模板生成的 `YunXiApp.swift` / `ContentView.swift`，把本工程
   `YunXi/` 目录下所有 `.swift` 文件拖进 Xcode 工程（勾选 Copy items）
3. 把 `YunXi/Resources/Assets.xcassets` 拖进工程（作为 folder reference 或 group 均可）
4. target 设置里确认：
   - **App Icon** = `AppIcon`
   - Info.plist 使用自带的 `Resources/Info.plist`（或直接删掉引用让 Xcode 自动生成，
     但 DisplayName 需手动改为「云析」）
5. 直接 ⌘R 运行

---

## 打包 IPA（巨魔 TrollStore 安装）

巨魔不校验签名，**未签名 IPA 也能装**，最省事：

```bash
cd yunxi-ios

# 1. 编译出 .app（无签名）
xcodebuild -project YunXi.xcodeproj \
  -scheme YunXi \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  clean build

# 2. 组装 Payload 并压成 .ipa
APP_PATH=$(find build -name "YunXi.app" -type d | head -1)
rm -rf Payload && mkdir Payload
cp -r "$APP_PATH" Payload/
zip -r YunXi.ipa Payload
```

把 `YunXi.ipa` 传到 iPhone（AirDrop / 文件 / 网盘均可），
用**巨魔（TrollStore）打开安装**即可，图标与名称即为「云析」。

> 备选：Xcode 里 Archive 后用 Organizer 导出， entitlements 已配好
> `get-task-allow`，Xcode 自动签名导出同样可被巨魔安装。

---

## 与原应用的对应关系

| 原应用（Android/Compose） | 本复刻（iOS/SwiftUI） |
|---|---|
| 4 Tab：解析/账号/下载/设置 | `ContentView.swift` TabView |
| 10 大网盘 + 7 大视频平台 | `CloudPlatform.swift` + 平台 logo 资产 |
| 主题色 10 套 + 自定义 + 动态色 | `ThemeManager.swift`（ThemeColor 枚举） |
| 外观：浅色/深色/跟随系统 | `AppearanceMode` + `preferredColorScheme` |
| 解析页：链接/提取码/粘贴/清空/开始解析 | `ParseView.swift` |
| 平台卡片：40dp 图标+状态+登录/管理 | `PlatformCard.swift` |
| 下载页：统计/进度「已下载 X / Y · Z%」/FAB | `DownloadsView.swift` |
| 设置：引擎/线程/分片/目录/后台/通知 | `SettingsView.swift` |
| 关于：chips「10 大网盘/7 大视频平台/分片下载/完全免费」 | `SettingsView.swift` aboutCard |

## 说明与边界

- 解析 / 下载目前是**界面与交互流程复刻**（演示数据），未接入真实网盘 API。
  原应用的解析调度逻辑在 `com.yunx.app` 的 YunX 下载调度架构中，如需移植真实
  解析能力，可基于 `AppStore` / `DownloadTask` 模型扩展网络层。
- 平台图标与应用图标均从原 APK 内提取（748² 放大至 1024²）。
- 本工程仅供个人学习与技术交流使用。
