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
    
    let ccusageCommand: String  // Made public for settings display
    
    init(ccusageCommand: String? = nil) {
        // If a specific command is provided, use it
        if let command = ccusageCommand {
            self.ccusageCommand = command
            return
        }
        
        // Get home directory
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        
        var foundPath: String? = nil
        
        // First, try to find ccusage in nvm installations
        let nvmPath = "\(homeDir)/.nvm/versions/node"
        if FileManager.default.fileExists(atPath: nvmPath) {
            do {
                let nodeVersions = try FileManager.default.contentsOfDirectory(atPath: nvmPath)
                // Sort versions to try newest first
                let sortedVersions = nodeVersions.sorted { $0.compare($1, options: .numeric) == .orderedDescending }
                
                for version in sortedVersions {
                    let ccusagePath = "\(nvmPath)/\(version)/bin/ccusage"
                    if FileManager.default.fileExists(atPath: ccusagePath) {
                        foundPath = ccusagePath
                        break
                    }
                }
            } catch {
                // Ignore errors and continue with fallback paths
            }
        }
        
        // If not found in nvm, check other common paths
        if foundPath == nil {
            let fallbackPaths = [
                "/usr/local/bin/ccusage",
                "/opt/homebrew/bin/ccusage",
                "\(homeDir)/.local/bin/ccusage",
                "/usr/bin/ccusage"
            ]
            
            for path in fallbackPaths {
                if FileManager.default.fileExists(atPath: path) {
                    foundPath = path
                    break
                }
            }
        }
        
        // Use the found path or fallback to "ccusage"
        if let found = foundPath {
            self.ccusageCommand = found
        } else {
            self.ccusageCommand = "ccusage"
        }
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
        
        // If ccusageCommand is a full path to an nvm-installed command, use node directly
        if ccusageCommand.contains("/.nvm/versions/node/") {
            // Extract the node path from the ccusage path
            let components = ccusageCommand.components(separatedBy: "/")
            if let binIndex = components.firstIndex(of: "bin"),
               binIndex > 0 {
                let nodePath = components[0..<binIndex].joined(separator: "/") + "/bin/node"
                if FileManager.default.fileExists(atPath: nodePath) {
                    task.launchPath = nodePath
                    task.arguments = [ccusageCommand] + arguments
                } else {
                    // Fallback to using the script directly
                    task.launchPath = ccusageCommand
                    task.arguments = arguments
                }
            } else {
                task.launchPath = ccusageCommand
                task.arguments = arguments
            }
        } else if ccusageCommand.hasPrefix("/") {
            // Other full paths - execute directly
            task.launchPath = ccusageCommand
            task.arguments = arguments
        } else {
            // Otherwise, use env to find it in PATH
            task.launchPath = "/usr/bin/env"
            task.arguments = [ccusageCommand] + arguments
        }
        
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