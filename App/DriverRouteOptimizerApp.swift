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
                        Label("Dashboard", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    }
                
                RouteMapView(viewModel: container.mapViewModel)
                    .tabItem {
                        Label("Map Route", systemImage: "map.fill")
                    }
                
                OrderListView(viewModel: container.orderListViewModel)
                    .tabItem {
                        Label("Orders", systemImage: "takeoutbag.and.cup.and.straw.fill")
                    }
                
                SettingsView(viewModel: container.settingsViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .accentColor(AppTheme.primaryOrange)
            .preferredColorScheme(.dark)
            .modelContainer(container.modelContainer)
        }
    }
}
