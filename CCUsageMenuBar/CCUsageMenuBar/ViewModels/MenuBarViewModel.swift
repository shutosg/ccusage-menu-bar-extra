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
                    lastUpdated = Date()
                    errorMessage = nil
                default:
                    break
                }
            }
        }
        
        isLoading = false
    }
}