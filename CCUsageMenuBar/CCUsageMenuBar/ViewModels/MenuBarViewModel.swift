import Foundation
import SwiftUI

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var todayCost: Double?
    @Published var todayTokens: Int?
    @Published var todayInputTokens: Int?
    @Published var todayOutputTokens: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var updateInterval: TimeInterval = 300 // 5 minutes default
    
    private let ccusageService = CCUsageService()
    private var updateTimer: Timer?
    
    init() {
        Task {
            await refresh()
        }
        startAutoUpdate()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let usage = try await ccusageService.fetchDailyUsage()
            todayCost = usage.totalCost
            todayTokens = usage.totalTokens
            todayInputTokens = usage.inputTokens
            todayOutputTokens = usage.outputTokens
            lastUpdated = Date()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching usage: \(error)")
            
            // If ccusage command not found, show helpful error
            if let ccusageError = error as? CCUsageService.CCUsageError {
                switch ccusageError {
                case .commandNotFound:
                    errorMessage = "ccusage not installed"
                case .noDataForToday:
                    // This is OK - just no usage today
                    todayCost = 0.0
                    todayTokens = 0
                    todayInputTokens = 0
                    todayOutputTokens = 0
                    lastUpdated = Date()
                    errorMessage = nil
                default:
                    break
                }
            }
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
    
    func setUpdateInterval(_ interval: TimeInterval) {
        updateInterval = interval
        if updateTimer != nil {
            startAutoUpdate() // Restart timer with new interval
        }
    }
}