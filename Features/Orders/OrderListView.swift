import SwiftUI

public struct OrderListView: View {
    @Bindable var viewModel: OrderListViewModel
    @State private var showingForm = false
    
    public init(viewModel: OrderListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                if viewModel.orders.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Delivery Orders")
                            .font(.headline)
                        Text("Tap + to add manual orders.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.orders) { order in
                            OrderCardView(order: order, onSelect: {})
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                let order = viewModel.orders[index]
                                Task { await viewModel.deleteOrder(id: order.id) }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Order Management")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingForm = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.primaryOrange)
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                OrderFormView(viewModel: viewModel, onOrderCreated: {
                    Task { await viewModel.fetchOrders() }
                })
            }
            .task {
                await viewModel.fetchOrders()
            }
        }
    }
}
