import Foundation
import ServiceManagement

class LaunchAtLogin {
    static let shared = LaunchAtLogin()
    
    private init() {}
    
    var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                // Fallback for older macOS versions
                return false
            }
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        if SMAppService.mainApp.status == .enabled {
                            // Already enabled
                            return
                        }
                        try SMAppService.mainApp.register()
                    } else {
                        if SMAppService.mainApp.status != .enabled {
                            // Already disabled
                            return
                        }
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error)")
                }
            }
        }
    }
    
    func toggle() {
        isEnabled.toggle()
    }
}