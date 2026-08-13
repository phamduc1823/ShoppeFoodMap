import SwiftUI
import SwiftData

@main
struct DriverRouteOptimizerApp: App {
    @StateObject private var container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView(viewModel: container.dashboardViewModel)
                    .tabItem {
                        Label("Dashboard", systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    }
                
                RouteMapView(viewModel: container.mapViewModel)
                    .tabItem {
                        Label("Map Route", systemName: "map.fill")
                    }
                
                OrderListView(viewModel: container.orderListViewModel)
                    .tabItem {
                        Label("Orders", systemName: "takeoutbag.and.cup.and.straw.fill")
                    }
                
                SettingsView(viewModel: container.settingsViewModel)
                    .tabItem {
                        Label("Settings", systemName: "gearshape.fill")
                    }
            }
            .accentColor(AppTheme.primaryOrange)
            .preferredColorScheme(.dark)
            .modelContainer(container.modelContainer)
        }
    }
}
