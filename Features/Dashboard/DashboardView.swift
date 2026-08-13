import SwiftUI

public struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    @State private var showingAddOrderSheet = false
    @State private var showingOrderAcceptanceSheet = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Top Online/Offline & GPS Header
                        StatusHeaderView(
                            isOnline: viewModel.networkMonitor.isConnected,
                            activeOrdersCount: viewModel.activeOrders.count,
                            isLocating: true,
                            onRefresh: {
                                Task { await viewModel.loadAndOptimize() }
                            }
                        )
                        
                        // Summary Metrics Cards
                        if let route = viewModel.currentRoute {
                            HStack(spacing: 12) {
                                MetricCardView(
                                    title: "Distance",
                                    value: String(format: "%.1f km", route.totalDistanceKm),
                                    iconName: "car.fill"
                                )
                                
                                MetricCardView(
                                    title: "Final ETA",
                                    value: route.estimatedCompletionTime != nil ? dateFormatter.string(from: route.estimatedCompletionTime!) : "--:--",
                                    subtitle: "~\(Int(route.totalTravelTimeMinutes)) min travel",
                                    iconName: "clock.fill",
                                    iconColor: AppTheme.accentTeal
                                )
                            }
                            
                            HStack(spacing: 12) {
                                MetricCardView(
                                    title: "Active Orders",
                                    value: "\(viewModel.activeOrders.count)",
                                    iconName: "takeoutbag.and.cup.and.straw.fill"
                                )
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "shield.checkerboard")
                                            .foregroundColor(AppTheme.color(forRisk: route.risk.riskLevel))
                                        Text("ROUTE RISK")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                    }
                                    RiskBadgeView(riskLevel: route.risk.riskLevel)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .glassmorphicCard()
                            }
                            
                            // Explanation Banner
                            if !route.explanation.isEmpty {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(AppTheme.primaryOrange)
                                    Text(route.explanation)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .padding(12)
                                .glassmorphicCard()
                            }
                            
                            // Route Stop Sequence List Header
                            HStack {
                                Text("RECOMMENDED SEQUENCE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            // Stop Sequence Rows
                            ForEach(route.stops) { stop in
                                RouteStopRowView(stop: stop, onCompleteStop: {
                                    Task { await viewModel.completeStop(stop) }
                                })
                            }
                        } else if viewModel.isLoading {
                            ProgressView("Calculating optimal route...")
                                .padding(40)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "tray.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No Active Orders")
                                    .font(.headline)
                                Text("Add a food delivery order to optimize your route.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(40)
                            .glassmorphicCard()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Driver Optimizer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddOrderSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primaryOrange)
                    }
                }
            }
            .task {
                await viewModel.loadAndOptimize()
            }
        }
    }
}
