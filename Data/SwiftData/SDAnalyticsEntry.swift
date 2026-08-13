import Foundation
import SwiftData

@Model
public final class SDAnalyticsEntry {
    @Attribute(.unique) public var id: UUID
    public var orderId: UUID
    public var stopTypeRaw: String
    public var plannedArrival: Date
    public var actualArrival: Date
    public var etaErrorSeconds: TimeInterval // actualArrival - plannedArrival
    public var timestamp: Date
    
    public init(
        id: UUID = UUID(),
        orderId: UUID,
        stopTypeRaw: String,
        plannedArrival: Date,
        actualArrival: Date,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.orderId = orderId
        self.stopTypeRaw = stopTypeRaw
        self.plannedArrival = plannedArrival
        self.actualArrival = actualArrival
        self.etaErrorSeconds = actualArrival.timeIntervalSince(plannedArrival)
        self.timestamp = timestamp
    }
}
