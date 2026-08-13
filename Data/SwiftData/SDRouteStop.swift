import Foundation
import SwiftData

@Model
public final class SDRouteStop {
    @Attribute(.unique) public var id: UUID
    public var orderId: UUID
    public var typeRaw: String
    public var sequence: Int
    public var latitude: Double
    public var longitude: Double
    public var locationName: String
    public var plannedArrival: Date?
    public var plannedDeparture: Date?
    public var actualArrival: Date?
    public var actualDeparture: Date?
    public var statusRaw: String
    public var deliveryWindowStart: Date?
    public var deliveryWindowEnd: Date?
    public var pickupReadyAt: Date?
    
    public init(from stop: RouteStop) {
        self.id = stop.id
        self.orderId = stop.orderId
        self.typeRaw = stop.type.rawValue
        self.sequence = stop.sequence
        self.latitude = stop.latitude
        self.longitude = stop.longitude
        self.locationName = stop.locationName
        self.plannedArrival = stop.plannedArrival
        self.plannedDeparture = stop.plannedDeparture
        self.actualArrival = stop.actualArrival
        self.actualDeparture = stop.actualDeparture
        self.statusRaw = stop.status.rawValue
        self.deliveryWindowStart = stop.deliveryWindowStart
        self.deliveryWindowEnd = stop.deliveryWindowEnd
        self.pickupReadyAt = stop.pickupReadyAt
    }
    
    public func toDomain() -> RouteStop {
        RouteStop(
            id: id,
            orderId: orderId,
            type: StopType(rawValue: typeRaw) ?? .pickup,
            sequence: sequence,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            plannedArrival: plannedArrival,
            plannedDeparture: plannedDeparture,
            actualArrival: actualArrival,
            actualDeparture: actualDeparture,
            status: StopStatus(rawValue: statusRaw) ?? .pending,
            deliveryWindowStart: deliveryWindowStart,
            deliveryWindowEnd: deliveryWindowEnd,
            pickupReadyAt: pickupReadyAt
        )
    }
}
