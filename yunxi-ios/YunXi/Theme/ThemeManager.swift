import SwiftUI

// MARK: - 主题色（对应原应用 10 套主题 + 自定义）

enum ThemeColor: String, CaseIterable, Identifiable {
    case blue = "默认蓝色"
    case purple = "紫色"
    case green = "绿色"
    case orange = "橙色"
    case red = "红色"
    case pink = "玫红"
    case gold = "金黄"
    case teal = "青色"
    case indigo = "靛蓝"
    case sky = "天蓝"

    var id: String { rawValue }

    var primary: Color {
        switch self {
        case .blue:   return Color(hex: 0x0B57D0)
        case .purple: return Color(hex: 0x6750A4)
        case .green:  return Color(hex: 0x1E8E3E)
        case .orange: return Color(hex: 0xE8710A)
        case .red:    return Color(hex: 0xD93025)
        case .pink:   return Color(hex: 0xC2185B)
        case .gold:   return Color(hex: 0xC79100)
        case .teal:   return Color(hex: 0x00796B)
        case .indigo: return Color(hex: 0x3F51B5)
        case .sky:    return Color(hex: 0x039BE5)
        }
    }

    /// 浅色模式容器色（tint 的淡化版，Material3 container 风格）
    var container: Color {
        primary.opacity(0.12)
    }
}

// MARK: - 外观模式（对应原应用三档）

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "浅色"
    case dark = "深色"
    case system = "跟随系统"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return nil
        }
    }
}

// MARK: - 十六进制颜色

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - 主题管理器

final class ThemeManager: ObservableObject {
    @AppStorage("themeColor") var themeColor: ThemeColor = .blue
    @AppStorage("appearance") var appearance: AppearanceMode = .light

    var primary: Color { themeColor.primary }
}
