import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    
    var body: some View {
        if viewModel.isLoading {
            Image(systemName: "arrow.clockwise")
        } else if let cost = viewModel.todayCost {
            Text("$\(cost, specifier: "%.2f")")
        } else {
            Image(systemName: "dollarsign.circle")
                .symbolRenderingMode(.hierarchical)
        }
    }
}