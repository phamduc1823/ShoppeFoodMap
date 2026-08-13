import Foundation
import SwiftUI

@Observable
public final class OrderAcceptanceViewModel: @unchecked Sendable {
    public private(set) var evaluation: DynamicInsertionEvaluation?
    public private(set) var isEvaluating: Bool = false
    public private(set) var errorMessage: String?
    
    private let insertionOptimizer: DynamicInsertionOptimizer
    private let repository: OrderRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    public init(
        insertionOptimizer: DynamicInsertionOptimizer,
        repository: OrderRepositoryProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.insertionOptimizer = insertionOptimizer
        self.repository = repository
        self.locationService = locationService
    }
    
    @MainActor
    public func evaluateNewOrder(_ newOrder: Order, currentRoute: RouteCandidate, existingOrders: [Order]) async {
        isEvaluating = true
        errorMessage = nil
        
        let driverPosition = locationService.currentLocation ?? Coordinate(latitude: 21.0285, longitude: 105.8542)
        
        do {
            evaluation = try await insertionOptimizer.evaluateInsertion(
                newOrder: newOrder,
                existingOrders: existingOrders,
                currentRoute: currentRoute,
                currentPosition: driverPosition,
                currentTime: Date()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isEvaluating = false
    }
    
    @MainActor
    public func acceptOrder(_ newOrder: Order) async throws {
        try await repository.saveOrder(newOrder)
    }
}
