import SwiftUI

struct MonthlyReportView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    let onClose: () -> Void
    @State private var monthlyData: MonthlyUsageData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Monthly Report")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                
                Button(action: {
                    Task {
                        await loadMonthlyData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isLoading)
            }
            .padding()
            
            Divider()
            
            // Content
            ScrollView {
                if isLoading {
                    ProgressView("Loading monthly data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let monthly = monthlyData {
                    VStack(alignment: .leading, spacing: 16) {
                        // Summary section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Cost")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("$\(monthly.totalCost, specifier: "%.2f")")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.accentColor)
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("Total Tokens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(monthly.totalTokens.formatted())")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Input Tokens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(monthly.inputTokens.formatted())")
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Output Tokens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(monthly.outputTokens.formatted())")
                                        .font(.headline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Model breakdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Model Usage")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            ForEach(monthly.modelBreakdowns, id: \.modelName) { model in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(model.modelName)
                                            .font(.subheadline)
                                        Text("\(model.inputTokens + model.outputTokens) tokens")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("$\(model.cost, specifier: "%.2f")")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 4)
                                
                                if model.modelName != monthly.modelBreakdowns.last?.modelName {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No data available")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                if let monthly = monthlyData {
                    Text("Month: \(monthly.month)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Close") {
                    onClose()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .task {
            await loadMonthlyData()
        }
    }
    
    private func loadMonthlyData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let service = CCUsageService()
            monthlyData = try await service.fetchMonthlyUsage()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading monthly data: \(error)")
        }
        
        isLoading = false
    }
}