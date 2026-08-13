import Foundation
import CoreLocation

/// Model representing a food delivery order.
public struct Order: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var orderNumber: String
    public var createdAt: Date
    
    // Pickup details
    public var restaurantName: String
    public var restaurantLatitude: Double
    public var restaurantLongitude: Double
    public var pickupReadyAt: Date
    public var pickupDeadline: Date
    
    // Delivery details
    public var customerName: String
    public var customerLatitude: Double
    public var customerLongitude: Double
    public var deliveryWindowStart: Date
    public var deliveryWindowEnd: Date
    
    // Status & Metadata
    public var status: OrderStatus
    public var priority: Int
    public var notes: String?
    public var estimatedPreparationTime: TimeInterval // seconds
    
    public init(
        id: UUID = UUID(),
        orderNumber: String,
        createdAt: Date = Date(),
        restaurantName: String,
        restaurantLatitude: Double,
        restaurantLongitude: Double,
        pickupReadyAt: Date,
        pickupDeadline: Date,
        customerName: String,
        customerLatitude: Double,
        customerLongitude: Double,
        deliveryWindowStart: Date,
        deliveryWindowEnd: Date,
        status: OrderStatus = .pending,
        priority: Int = 1,
        notes: String? = nil,
        estimatedPreparationTime: TimeInterval = 600 // default 10 mins
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.createdAt = createdAt
        self.restaurantName = restaurantName
        self.restaurantLatitude = restaurantLatitude
        self.restaurantLongitude = restaurantLongitude
        self.pickupReadyAt = pickupReadyAt
        self.pickupDeadline = pickupDeadline
        self.customerName = customerName
        self.customerLatitude = customerLatitude
        self.customerLongitude = customerLongitude
        self.deliveryWindowStart = deliveryWindowStart
        self.deliveryWindowEnd = deliveryWindowEnd
        self.status = status
        self.priority = priority
        self.notes = notes
        self.estimatedPreparationTime = estimatedPreparationTime
    }
    
    public var restaurantCoordinate: Coordinate {
        Coordinate(latitude: restaurantLatitude, longitude: restaurantLongitude)
    }
    
    public var customerCoordinate: Coordinate {
        Coordinate(latitude: customerLatitude, longitude: customerLongitude)
    }
}
