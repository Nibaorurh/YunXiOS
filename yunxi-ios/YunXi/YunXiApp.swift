import SwiftUI

@main
struct YunXiApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(store)
                .preferredColorScheme(theme.appearance.colorScheme)
        }
    }
}
