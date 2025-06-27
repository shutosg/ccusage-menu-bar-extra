import Foundation

struct DailyUsage {
    let totalCost: Double
    let totalTokens: Int
    let date: Date
}

class CCUsageService {
    enum CCUsageError: LocalizedError {
        case commandNotFound
        case executionFailed(String)
        case invalidJSON
        
        var errorDescription: String? {
            switch self {
            case .commandNotFound:
                return "ccusage command not found"
            case .executionFailed(let message):
                return "Command failed: \(message)"
            case .invalidJSON:
                return "Invalid JSON response"
            }
        }
    }
    
    func fetchDailyUsage() async throws -> DailyUsage {
        // TODO: Implement actual ccusage command execution
        // For now, return mock data
        return DailyUsage(
            totalCost: 23.45,
            totalTokens: 456789,
            date: Date()
        )
    }
}