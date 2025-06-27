import Foundation

struct AppSettings: Codable {
    var updateInterval: TimeInterval
    var autoLaunchAtLogin: Bool
    
    static let defaultSettings = AppSettings(
        updateInterval: 300, // 5 minutes
        autoLaunchAtLogin: false
    )
}

@MainActor
class SettingsManager: ObservableObject {
    private let settingsKey = "CCUsageAppSettings"
    
    @Published var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }
    
    init() {
        self.settings = Self.loadSettings()
    }
    
    private static func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "CCUsageAppSettings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings.defaultSettings
        }
        return settings
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    func resetToDefaults() {
        settings = AppSettings.defaultSettings
    }
}