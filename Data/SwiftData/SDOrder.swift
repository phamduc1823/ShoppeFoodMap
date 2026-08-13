import Foundation
import SwiftData

@Model
public final class SDOrder {
    @Attribute(.unique) public var id: UUID
    public var orderNumber: String
    public var createdAt: Date
    
    public var restaurantName: String
    public var restaurantLatitude: Double
    public var restaurantLongitude: Double
    public var pickupReadyAt: Date
    public var pickupDeadline: Date
    
    public var customerName: String
    public var customerLatitude: Double
    public var customerLongitude: Double
    public var deliveryWindowStart: Date
    public var deliveryWindowEnd: Date
    
    public var statusRaw: String
    public var priority: Int
    public var notes: String?
    public var estimatedPreparationTime: TimeInterval
    
    public init(from order: Order) {
        self.id = order.id
        self.orderNumber = order.orderNumber
        self.createdAt = order.createdAt
        self.restaurantName = order.restaurantName
        self.restaurantLatitude = order.restaurantLatitude
        self.restaurantLongitude = order.restaurantLongitude
        self.pickupReadyAt = order.pickupReadyAt
        self.pickupDeadline = order.pickupDeadline
        self.customerName = order.customerName
        self.customerLatitude = order.customerLatitude
        self.customerLongitude = order.customerLongitude
        self.deliveryWindowStart = order.deliveryWindowStart
        self.deliveryWindowEnd = order.deliveryWindowEnd
        self.statusRaw = order.status.rawValue
        self.priority = order.priority
        self.notes = order.notes
        self.estimatedPreparationTime = order.estimatedPreparationTime
    }
    
    public func toDomain() -> Order {
        Order(
            id: id,
            orderNumber: orderNumber,
            createdAt: createdAt,
            restaurantName: restaurantName,
            restaurantLatitude: restaurantLatitude,
            restaurantLongitude: restaurantLongitude,
            pickupReadyAt: pickupReadyAt,
            pickupDeadline: pickupDeadline,
            customerName: customerName,
            customerLatitude: customerLatitude,
            customerLongitude: customerLongitude,
            deliveryWindowStart: deliveryWindowStart,
            deliveryWindowEnd: deliveryWindowEnd,
            status: OrderStatus(rawValue: statusRaw) ?? .pending,
            priority: priority,
            notes: notes,
            estimatedPreparationTime: estimatedPreparationTime
        )
    }
}
