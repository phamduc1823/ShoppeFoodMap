import Foundation
import SwiftData

@MainActor
public final class SwiftDataOrderRepository: OrderRepositoryProtocol {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    public func fetchAllOrders() async throws -> [Order] {
        let descriptor = FetchDescriptor<SDOrder>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let sdOrders = try modelContext.fetch(descriptor)
        return sdOrders.map { $0.toDomain() }
    }
    
    public func fetchActiveOrders() async throws -> [Order] {
        let all = try await fetchAllOrders()
        return all.filter { $0.status.isActive }
    }
    
    public func fetchOrder(id: UUID) async throws -> Order? {
        let descriptor = FetchDescriptor<SDOrder>(predicate: #Predicate { $0.id == id })
        let sdOrders = try modelContext.fetch(descriptor)
        return sdOrders.first?.toDomain()
    }
    
    public func saveOrder(_ order: Order) async throws {
        let descriptor = FetchDescriptor<SDOrder>(predicate: #Predicate { $0.id == order.id })
        let existing = try modelContext.fetch(descriptor).first
        
        if let existing = existing {
            existing.orderNumber = order.orderNumber
            existing.restaurantName = order.restaurantName
            existing.restaurantLatitude = order.restaurantLatitude
            existing.restaurantLongitude = order.restaurantLongitude
            existing.pickupReadyAt = order.pickupReadyAt
            existing.pickupDeadline = order.pickupDeadline
            existing.customerName = order.customerName
            existing.customerLatitude = order.customerLatitude
            existing.customerLongitude = order.customerLongitude
            existing.deliveryWindowStart = order.deliveryWindowStart
            existing.deliveryWindowEnd = order.deliveryWindowEnd
            existing.statusRaw = order.status.rawValue
            existing.priority = order.priority
            existing.notes = order.notes
            existing.estimatedPreparationTime = order.estimatedPreparationTime
        } else {
            let sdOrder = SDOrder(from: order)
            modelContext.insert(sdOrder)
        }
        
        try modelContext.save()
    }
    
    public func updateOrderStatus(id: UUID, status: OrderStatus) async throws {
        let descriptor = FetchDescriptor<SDOrder>(predicate: #Predicate { $0.id == id })
        if let existing = try modelContext.fetch(descriptor).first {
            existing.statusRaw = status.rawValue
            try modelContext.save()
        }
    }
    
    public func deleteOrder(id: UUID) async throws {
        let descriptor = FetchDescriptor<SDOrder>(predicate: #Predicate { $0.id == id })
        if let existing = try modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
            try modelContext.save()
        }
    }
    
    public func recordAnalytics(entry: SDAnalyticsEntry) async throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
}
