import Foundation

struct AppSettings: Codable {
    var updateInterval: TimeInterval
    var autoLaunchAtLogin: Bool
    var jsonlFilePath: String?
    var ccusageCommandPath: String?
    
    static let defaultSettings = AppSettings(
        updateInterval: 300, // 5 minutes
        autoLaunchAtLogin: false,
        jsonlFilePath: nil,
        ccusageCommandPath: nil
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
        
        // Sync launch at login with system setting
        syncLaunchAtLogin()
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
        
        // Update launch at login
        LaunchAtLogin.shared.isEnabled = settings.autoLaunchAtLogin
    }
    
    private func syncLaunchAtLogin() {
        // Sync the setting with the actual system state
        let systemState = LaunchAtLogin.shared.isEnabled
        if settings.autoLaunchAtLogin != systemState {
            settings.autoLaunchAtLogin = systemState
        }
    }
    
    func resetToDefaults() {
        settings = AppSettings.defaultSettings
    }
}