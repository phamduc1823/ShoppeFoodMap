import Foundation
import SwiftUI
import SwiftData

@MainActor
public final class AppContainer: ObservableObject {
    public let modelContainer: ModelContainer
    public let repository: OrderRepositoryProtocol
    public let locationService: LocationServiceProtocol
    public let routingService: RoutingServiceProtocol
    public let optimizer: RouteOptimizerProtocol
    public let insertionOptimizer: DynamicInsertionOptimizer
    
    public let dashboardViewModel: DashboardViewModel
    public let orderListViewModel: OrderListViewModel
    public let mapViewModel: MapViewModel
    public let settingsViewModel: SettingsViewModel
    
    public init() {
        do {
            let schema = Schema([
                SDOrder.self,
                SDRouteStop.self,
                SDRouteCache.self,
                SDAnalyticsEntry.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
        
        let repo = SwiftDataOrderRepository(modelContainer: self.modelContainer)
        self.repository = repo
        
        let location = LocationService()
        self.locationService = location
        
        let cache = RouteCacheService(modelContainer: self.modelContainer)
        let hybridRouting = HybridRoutingService(cacheService: cache)
        self.routingService = hybridRouting
        
        let optConfig = OptimizationConfiguration.default
        let optimizerEngine = RouteOptimizer(routingService: hybridRouting, config: optConfig)
        self.optimizer = optimizerEngine
        self.insertionOptimizer = DynamicInsertionOptimizer(optimizer: optimizerEngine)
        
        self.dashboardViewModel = DashboardViewModel(
            repository: repo,
            optimizer: optimizerEngine,
            locationService: location
        )
        
        self.orderListViewModel = OrderListViewModel(repository: repo)
        self.mapViewModel = MapViewModel(locationService: location)
        self.settingsViewModel = SettingsViewModel(config: optConfig)
        
        // Populate sample scenario orders on first launch if empty
        Task {
            try? await self.seedSampleOrdersIfEmpty()
        }
    }
    
    private func seedSampleOrdersIfEmpty() async throws {
        let existing = try await repository.fetchAllOrders()
        guard existing.isEmpty else { return }
        
        let now = Date()
        
        // Scenario Sample Order A
        let orderA = Order(
            orderNumber: "A101",
            createdAt: now,
            restaurantName: "Phở Thin (Restaurant A)",
            restaurantLatitude: 21.0255,
            restaurantLongitude: 105.8575,
            pickupReadyAt: now.addingTimeInterval(300), // 5 mins
            pickupDeadline: now.addingTimeInterval(1200),
            customerName: "Customer A (Hoan Kiem)",
            customerLatitude: 21.0320,
            customerLongitude: 105.8500,
            deliveryWindowStart: now.addingTimeInterval(1800), // 30 mins
            deliveryWindowEnd: now.addingTimeInterval(2400)    // 40 mins
        )
        
        // Scenario Sample Order B
        let orderB = Order(
            orderNumber: "B102",
            createdAt: now.addingTimeInterval(300),
            restaurantName: "Bún Chả Huống (Restaurant B)",
            restaurantLatitude: 21.0180,
            restaurantLongitude: 105.8450,
            pickupReadyAt: now.addingTimeInterval(600), // 10 mins
            pickupDeadline: now.addingTimeInterval(1800),
            customerName: "Customer B (Hai Ba Trung)",
            customerLatitude: 21.0100,
            customerLongitude: 105.8400,
            deliveryWindowStart: now.addingTimeInterval(2400), // 40 mins
            deliveryWindowEnd: now.addingTimeInterval(3000)    // 50 mins
        )
        
        try await repository.saveOrder(orderA)
        try await repository.saveOrder(orderB)
    }
}
