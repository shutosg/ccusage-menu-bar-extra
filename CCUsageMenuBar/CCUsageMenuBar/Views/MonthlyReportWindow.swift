import SwiftUI
import AppKit

class MonthlyReportWindowController: ObservableObject {
    private var reportWindow: NSWindow?
    
    func showMonthlyReport(viewModel: MenuBarViewModel) {
        if let existingWindow = reportWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let reportView = MonthlyReportView(viewModel: viewModel) { [weak self] in
            self?.closeReport()
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "CCUsage Monthly Report"
        window.contentView = NSHostingView(rootView: reportView)
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.minSize = NSSize(width: 400, height: 500)
        
        reportWindow = window
        
        // Ensure the app is active before showing the window
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func closeReport() {
        reportWindow?.close()
        reportWindow = nil
    }
}