import Foundation

// MARK: - Daily Usage Response
struct DailyUsageResponse: Codable {
    let daily: [DailyUsageData]
}

// MARK: - Daily Usage Data
struct DailyUsageData: Codable {
    let date: String
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let totalCost: Double
    let modelsUsed: [String]
    let modelBreakdowns: [ModelBreakdown]
    
    var formattedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}

// MARK: - Model Breakdown
struct ModelBreakdown: Codable {
    let modelName: String
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let cost: Double
}

// MARK: - Monthly Usage Response
struct MonthlyUsageResponse: Codable {
    let monthly: [MonthlyUsageData]
}

// MARK: - Monthly Usage Data
struct MonthlyUsageData: Codable {
    let month: String
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
    let totalCost: Double
    let modelsUsed: [String]
    let modelBreakdowns: [ModelBreakdown]
    
    var formattedMonth: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.date(from: month)
    }
}