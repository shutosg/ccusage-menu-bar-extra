import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    let onClose: () -> Void
    
    // Local state for settings
    @State private var selectedInterval: TimeInterval
    @State private var jsonlFilePath: String
    @State private var ccusageCommandPath: String
    
    init(viewModel: MenuBarViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
        self._selectedInterval = State(initialValue: viewModel.updateInterval)
        
        // Initialize with current values
        let currentJsonlPath = viewModel.settingsManager.settings.jsonlFilePath ?? viewModel.ccusageService.jsonlFilePath ?? ""
        self._jsonlFilePath = State(initialValue: currentJsonlPath)
        
        let currentCCUsagePath = viewModel.settingsManager.settings.ccusageCommandPath ?? viewModel.ccusageService.ccusageCommand
        self._ccusageCommandPath = State(initialValue: currentCCUsagePath)
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
                            HStack {
                                TextField("Leave empty for default", text: $jsonlFilePath)
                                    .font(.system(.body, design: .monospaced))
                                    .textFieldStyle(.roundedBorder)
                                Button("Default") {
                                    jsonlFilePath = ""
                                }
                                .font(.caption)
                            }
                            Text("Default: ~/.claude/code/usage_logs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ccusage Command Path")
                                .font(.body)
                            HStack {
                                TextField("Leave empty for auto-detect", text: $ccusageCommandPath)
                                    .font(.system(.body, design: .monospaced))
                                    .textFieldStyle(.roundedBorder)
                                Button("Auto") {
                                    ccusageCommandPath = ""
                                }
                                .font(.caption)
                            }
                            Text("Current: \(viewModel.ccusageService.ccusageCommand)")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                    // Apply interval setting
                    viewModel.updateInterval = selectedInterval
                    
                    // Apply path settings
                    viewModel.settingsManager.settings.jsonlFilePath = jsonlFilePath.isEmpty ? nil : jsonlFilePath
                    viewModel.settingsManager.settings.ccusageCommandPath = ccusageCommandPath.isEmpty ? nil : ccusageCommandPath
                    
                    // Update the service with new paths
                    viewModel.updatePaths(
                        ccusageCommand: ccusageCommandPath.isEmpty ? nil : ccusageCommandPath,
                        jsonlPath: jsonlFilePath.isEmpty ? nil : jsonlFilePath
                    )
                    
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 450, height: 420)
    }
}

#Preview {
    SettingsView(viewModel: MenuBarViewModel(), onClose: {})
}