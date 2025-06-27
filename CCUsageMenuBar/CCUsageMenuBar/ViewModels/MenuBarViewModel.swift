import Foundation
import SwiftUI

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var todayCost: Double?
    @Published var todayTokens: Int?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    
    private let ccusageService = CCUsageService()
    
    func refresh() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let usage = try await ccusageService.fetchDailyUsage()
            todayCost = usage.totalCost
            todayTokens = usage.totalTokens
            lastUpdated = Date()
        } catch {
            errorMessage = error.localizedDescription
            // For now, use mock data if ccusage fails
            if errorMessage?.contains("not found") ?? false {
                // Mock data for development
                todayCost = 12.45
                todayTokens = 250000
                lastUpdated = Date()
                errorMessage = nil
            }
        }
        
        isLoading = false
    }
}