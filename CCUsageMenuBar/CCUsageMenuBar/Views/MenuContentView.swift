import SwiftUI

struct MenuContentView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    
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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("$\(cost, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("\(tokens.formatted()) tokens")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
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
            
            // Actions
            VStack(spacing: 4) {
                Button(action: {
                    Task {
                        await viewModel.refresh()
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
                    // TODO: Implement settings
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
            
            // Last updated
            if let lastUpdated = viewModel.lastUpdated {
                Divider()
                Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .frame(width: 250)
        .task {
            await viewModel.refresh()
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}