import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    let onClose: () -> Void
    
    // Local state for settings
    @State private var selectedInterval: TimeInterval
    
    init(viewModel: MenuBarViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
        self._selectedInterval = State(initialValue: viewModel.updateInterval)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            
            Divider()
            
            // Settings content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // General Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("General")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update Interval")
                                .font(.body)
                            
                            Picker("Update Interval", selection: $selectedInterval) {
                                Text("1 minute").tag(TimeInterval(60))
                                Text("3 minutes").tag(TimeInterval(180))
                                Text("5 minutes").tag(TimeInterval(300))
                                Text("10 minutes").tag(TimeInterval(600))
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                    }
                    
                    Divider()
                    
                    // Data Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("JSONL File Path")
                                .font(.body)
                            Text("~/.claude/code/usage_logs")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ccusage Command Path")
                                .font(.body)
                            Text("ccusage")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer buttons
            HStack {
                Button("Cancel") {
                    onClose()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    // Apply settings
                    viewModel.setUpdateInterval(selectedInterval)
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 350)
    }
}

#Preview {
    SettingsView(viewModel: MenuBarViewModel(), onClose: {})
}