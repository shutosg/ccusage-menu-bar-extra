import SwiftUI
import AppKit

class SettingsWindowController: ObservableObject {
    private var settingsWindow: NSWindow?
    
    func showSettings(viewModel: MenuBarViewModel) {
        if let existingWindow = settingsWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let settingsView = SettingsView(viewModel: viewModel) { [weak self] in
            self?.closeSettings()
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "CCUsage Settings"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        
        settingsWindow = window
        
        // Ensure the app is active before showing the window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        window.makeKeyAndOrderFront(nil)
    }
    
    private func closeSettings() {
        settingsWindow?.close()
        settingsWindow = nil
    }
}