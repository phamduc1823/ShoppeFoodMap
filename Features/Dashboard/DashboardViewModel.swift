import Foundation
import SwiftUI
import Combine

@Observable
public final class DashboardViewModel: @unchecked Sendable {
    public private(set) var activeOrders: [Order] = []
    public private(set) var currentRoute: RouteCandidate?
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    private let repository: OrderRepositoryProtocol
    private let optimizer: RouteOptimizerProtocol
    private let locationService: LocationServiceProtocol
    public let networkMonitor: NetworkMonitor
    
    public init(
        repository: OrderRepositoryProtocol,
        optimizer: RouteOptimizerProtocol,
        locationService: LocationServiceProtocol,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.repository = repository
        self.optimizer = optimizer
        self.locationService = locationService
        self.networkMonitor = networkMonitor
    }
    
    @MainActor
    public func loadAndOptimize() async {
        isLoading = true
        errorMessage = nil
        
        do {
            activeOrders = try await repository.fetchActiveOrders()
            
            // Fallback default driver position if GPS not available (e.g. Hanoi city center)
            let driverPosition = locationService.currentLocation ?? Coordinate(latitude: 21.0285, longitude: 105.8542)
            
            if !activeOrders.isEmpty {
                currentRoute = try await optimizer.optimize(
                    orders: activeOrders,
                    currentPosition: driverPosition,
                    currentTime: Date()
                )
            } else {
                currentRoute = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    public func completeStop(_ stop: RouteStop) async {
        guard let order = activeOrders.first(where: { $0.id == stop.orderId }) else { return }
        
        var updatedStatus = order.status
        if stop.type == .pickup {
            updatedStatus = .pickedUp
        } else if stop.type == .delivery {
            updatedStatus = .delivered
        }
        
        do {
            try await repository.updateOrderStatus(id: order.id, status: updatedStatus)
            await loadAndOptimize()
        } catch {
            errorMessage = "Failed to update order status: \(error.localizedDescription)"
        }
    }
}
