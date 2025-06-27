import Foundation

class CCUsageService {
    enum CCUsageError: LocalizedError {
        case commandNotFound
        case executionFailed(String)
        case invalidJSON
        case noDataForToday
        
        var errorDescription: String? {
            switch self {
            case .commandNotFound:
                return "ccusage command not found"
            case .executionFailed(let message):
                return "Command failed: \(message)"
            case .invalidJSON:
                return "Invalid JSON response"
            case .noDataForToday:
                return "No usage data for today"
            }
        }
    }
    
    private let ccusageCommand: String
    
    init(ccusageCommand: String = "ccusage") {
        self.ccusageCommand = ccusageCommand
    }
    
    func fetchDailyUsage() async throws -> DailyUsageData {
        let output = try await executeCCUsage(arguments: ["daily", "--json"])
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(DailyUsageResponse.self, from: output)
        
        // Get today's date string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        // Find today's data
        guard let todayData = response.daily.first(where: { $0.date == todayString }) else {
            throw CCUsageError.noDataForToday
        }
        
        return todayData
    }
    
    func fetchMonthlyUsage() async throws -> MonthlyUsageData {
        let output = try await executeCCUsage(arguments: ["monthly", "--json"])
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(MonthlyUsageResponse.self, from: output)
        
        // Get current month string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let currentMonthString = formatter.string(from: Date())
        
        // Find current month's data
        guard let currentMonthData = response.monthly.first(where: { $0.month == currentMonthString }) else {
            // If no data for current month, create empty data
            return MonthlyUsageData(
                month: currentMonthString,
                inputTokens: 0,
                outputTokens: 0,
                cacheCreationTokens: 0,
                cacheReadTokens: 0,
                totalTokens: 0,
                totalCost: 0.0,
                modelsUsed: [],
                modelBreakdowns: []
            )
        }
        
        return currentMonthData
    }
    
    private func executeCCUsage(arguments: [String]) async throws -> Data {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = [ccusageCommand] + arguments
        
        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                task.terminationHandler = { process in
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    if process.terminationStatus != 0 {
                        let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: CCUsageError.executionFailed(errorString))
                        return
                    }
                    
                    if data.isEmpty {
                        continuation.resume(throwing: CCUsageError.invalidJSON)
                        return
                    }
                    
                    continuation.resume(returning: data)
                }
                
                try task.run()
            } catch {
                continuation.resume(throwing: CCUsageError.commandNotFound)
            }
        }
    }
}