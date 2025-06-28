import Foundation
import SwiftUI

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var todayCost: Double?
    @Published var todayTokens: Int?
    @Published var todayInputTokens: Int?
    @Published var todayOutputTokens: Int?
    @Published var monthlyData: MonthlyUsageData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var updateInterval: TimeInterval {
        didSet {
            settingsManager.settings.updateInterval = updateInterval
            if updateTimer != nil {
                startAutoUpdate()
            }
        }
    }
    
    var ccusageService: CCUsageService  // Made public for settings display
    let settingsManager = SettingsManager()
    private var updateTimer: Timer?
    
    // Error tracking
    private var errorCount = 0
    private let maxConsecutiveErrors = 5
    
    init() {
        // Load saved settings
        self.updateInterval = settingsManager.settings.updateInterval
        
        // Initialize CCUsageService with custom paths if available
        self.ccusageService = CCUsageService(
            ccusageCommand: settingsManager.settings.ccusageCommandPath,
            jsonlFilePath: settingsManager.settings.jsonlFilePath
        )
        
        Task {
            await refresh()
        }
        startAutoUpdate()
    }
    
    func updatePaths(ccusageCommand: String?, jsonlPath: String?) {
        // Update the service with new paths
        self.ccusageService = CCUsageService(
            ccusageCommand: ccusageCommand?.isEmpty == false ? ccusageCommand : nil,
            jsonlFilePath: jsonlPath?.isEmpty == false ? jsonlPath : nil
        )
        
        // Refresh data with new settings
        Task {
            await refresh()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
        // Fetch daily usage
        do {
            let usage = try await ccusageService.fetchDailyUsage()
            todayCost = usage.totalCost
            todayTokens = usage.totalTokens
            todayInputTokens = usage.inputTokens
            todayOutputTokens = usage.outputTokens
            lastUpdated = Date()
            errorMessage = nil
            errorCount = 0 // Reset error count on success
        } catch {
            handleError(error)
        }
        
        // Fetch monthly usage
        do {
            monthlyData = try await ccusageService.fetchMonthlyUsage()
        } catch {
            print("Error fetching monthly usage: \(error)")
            monthlyData = nil
        }
        
        isLoading = false
    }
    
    func startAutoUpdate() {
        stopAutoUpdate() // Stop any existing timer
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            Task { @MainActor in
                await self.refresh()
            }
        }
    }
    
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        errorCount += 1
        
        // Special handling for specific errors
        if let ccusageError = error as? CCUsageService.CCUsageError {
            switch ccusageError {
            case .commandNotFound:
                errorMessage = "ccusage not installed. Please install via: npm install -g ccusage"
            case .noDataForToday:
                // This is OK - just no usage today
                todayCost = 0.0
                todayTokens = 0
                todayInputTokens = 0
                todayOutputTokens = 0
                lastUpdated = Date()
                errorMessage = nil
                errorCount = 0 // Reset error count
                return
            case .executionFailed(let message, _):
                // Check for common Node.js errors
                if message.contains("Cannot find module") && message.contains("ccusage") {
                    errorMessage = "ccusage not found. Please reinstall: npm install -g ccusage"
                } else if message.contains("node:") && message.contains("not found") {
                    errorMessage = "Node.js not found. Please install Node.js first."
                } else if message.contains("EACCES") || message.contains("permission denied") {
                    errorMessage = "Permission denied. Try reinstalling ccusage with sudo."
                } else {
                    // For other errors, show a simplified message
                    errorMessage = "Failed to run ccusage. Check if it's properly installed."
                }
            case .filePermissionDenied:
                errorMessage = "Permission denied. Check file permissions in Settings."
            case .timeout:
                errorMessage = "Request timed out. Will retry on next update."
            case .invalidJSON:
                errorMessage = "Invalid response from ccusage. Please check the installation."
            default:
                errorMessage = getUserFriendlyErrorMessage(error)
            }
        } else {
            errorMessage = getUserFriendlyErrorMessage(error)
        }
        
        // Stop auto-updates after too many errors
        if errorCount >= 5 {
            stopAutoUpdate()
            errorMessage = "\(errorMessage ?? "") Auto-updates paused due to repeated errors."
        }
    }
    
    private func getUserFriendlyErrorMessage(_ error: Error) -> String {
        if let ccusageError = error as? CCUsageService.CCUsageError {
            return ccusageError.localizedDescription
        }
        return "An error occurred: \(error.localizedDescription)"
    }
}