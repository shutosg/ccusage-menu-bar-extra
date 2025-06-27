import SwiftUI

struct MenuContentView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    private let settingsWindowController = SettingsWindowController()
    @State private var monthlyData: MonthlyUsageData?
    @State private var isLoadingMonthly = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("CCUsage")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 4)

            Divider()

            // Today's usage
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Usage")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let cost = viewModel.todayCost,
                          let tokens = viewModel.todayTokens {
                    VStack(alignment: .leading, spacing: 8) {
                        // Total cost
                        Text("$\(cost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Token details - same layout as monthly
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(tokens.formatted())")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Input")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.todayInputTokens?.formatted() ?? "0")")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Output")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.todayOutputTokens?.formatted() ?? "0")")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text("No data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)

            Divider()
            
            // Monthly usage
            VStack(alignment: .leading, spacing: 4) {
                Text("This Month")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isLoadingMonthly {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let monthly = monthlyData {
                    VStack(alignment: .leading, spacing: 8) {
                        // Total cost - same as today's cost
                        Text("$\(monthly.totalCost, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Token details - smaller
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(monthly.totalTokens.formatted())")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Input")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(monthly.inputTokens.formatted())")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Output")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(monthly.outputTokens.formatted())")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                } else {
                    Text("No monthly data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)

            Divider()

            // Actions
            VStack(spacing: 4) {
                Button(action: {
                    Task {
                        await viewModel.refresh()
                        await loadMonthlyData()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
                

                Button(action: {
                    settingsWindowController.showSettings(viewModel: viewModel)
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings...")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)

                Divider()

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }

            // Last updated and auto-update info
            if let lastUpdated = viewModel.lastUpdated {
                Divider()
                VStack(spacing: 2) {
                    Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Auto-updates every \(Int(viewModel.updateInterval / 60)) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .frame(width: 250)
        .task {
            await viewModel.refresh()
            await loadMonthlyData()
        }
    }
    
    private func loadMonthlyData() async {
        isLoadingMonthly = true
        
        do {
            let service = CCUsageService()
            monthlyData = try await service.fetchMonthlyUsage()
        } catch {
            print("Error loading monthly data: \(error)")
            monthlyData = nil
        }
        
        isLoadingMonthly = false
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}