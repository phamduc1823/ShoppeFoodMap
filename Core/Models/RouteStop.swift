import Foundation

public enum StopStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case completed
    case skipped
}

/// Model representing a single stop in a delivery route.
public struct RouteStop: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let orderId: UUID
    public let type: StopType
    public var sequence: Int
    public var latitude: Double
    public var longitude: Double
    public var locationName: String
    
    // Arrival and departure estimates & actuals
    public var plannedArrival: Date?
    public var plannedDeparture: Date?
    public var actualArrival: Date?
    public var actualDeparture: Date?
    public var status: StopStatus
    
    // Window constraints
    public var deliveryWindowStart: Date?
    public var deliveryWindowEnd: Date?
    public var pickupReadyAt: Date?
    
    public init(
        id: UUID = UUID(),
        orderId: UUID,
        type: StopType,
        sequence: Int,
        latitude: Double,
        longitude: Double,
        locationName: String,
        plannedArrival: Date? = nil,
        plannedDeparture: Date? = nil,
        actualArrival: Date? = nil,
        actualDeparture: Date? = nil,
        status: StopStatus = .pending,
        deliveryWindowStart: Date? = nil,
        deliveryWindowEnd: Date? = nil,
        pickupReadyAt: Date? = nil
    ) {
        self.id = id
        self.orderId = orderId
        self.type = type
        self.sequence = sequence
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.plannedArrival = plannedArrival
        self.plannedDeparture = plannedDeparture
        self.actualArrival = actualArrival
        self.actualDeparture = actualDeparture
        self.status = status
        self.deliveryWindowStart = deliveryWindowStart
        self.deliveryWindowEnd = deliveryWindowEnd
        self.pickupReadyAt = pickupReadyAt
    }
    
    public var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}
