import SwiftUI

@main
struct CCUsageMenuBarApp: App {
    @StateObject private var viewModel = MenuBarViewModel()
    
    var body: some Scene {
        MenuBarExtra(
            viewModel.todayCost != nil ? "$\(viewModel.todayCost!, specifier: "%.2f")" : "CCUsage"
        ) {
            MenuContentView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}