import Foundation
import SwiftUI

@Observable
public final class OrderListViewModel: @unchecked Sendable {
    public private(set) var orders: [Order] = []
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    private let repository: OrderRepositoryProtocol
    private let geocodingService: GeocodingServiceProtocol
    
    public init(
        repository: OrderRepositoryProtocol,
        geocodingService: GeocodingServiceProtocol = AppleGeocodingService()
    ) {
        self.repository = repository
        self.geocodingService = geocodingService
    }
    
    @MainActor
    public func fetchOrders() async {
        isLoading = true
        do {
            orders = try await repository.fetchAllOrders()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    public func createOrder(
        orderNumber: String,
        restaurantName: String,
        restaurantAddress: String,
        customerName: String,
        customerAddress: String,
        deliveryWindowStart: Date,
        deliveryWindowEnd: Date,
        pickupReadyAt: Date,
        estimatedPreparationTime: TimeInterval
    ) async throws {
        // Geocode restaurant address & customer address
        let restCoord = try await geocodingService.geocodeAddress(restaurantAddress)
        let custCoord = try await geocodingService.geocodeAddress(customerAddress)
        
        let newOrder = Order(
            orderNumber: orderNumber,
            restaurantName: restaurantName,
            restaurantLatitude: restCoord.latitude,
            restaurantLongitude: restCoord.longitude,
            pickupReadyAt: pickupReadyAt,
            pickupDeadline: pickupReadyAt.addingTimeInterval(1800),
            customerName: customerName,
            customerLatitude: custCoord.latitude,
            customerLongitude: custCoord.longitude,
            deliveryWindowStart: deliveryWindowStart,
            deliveryWindowEnd: deliveryWindowEnd,
            estimatedPreparationTime: estimatedPreparationTime
        )
        
        try await repository.saveOrder(newOrder)
        await fetchOrders()
    }
    
    @MainActor
    public func deleteOrder(id: UUID) async {
        try? await repository.deleteOrder(id: id)
        await fetchOrders()
    }
}
