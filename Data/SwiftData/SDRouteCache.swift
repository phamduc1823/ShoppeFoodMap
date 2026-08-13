import Foundation
import SwiftData

@Model
public final class SDRouteCache {
    @Attribute(.unique) public var cacheKey: String
    public var originLat: Double
    public var originLon: Double
    public var destLat: Double
    public var destLon: Double
    public var distanceMeters: Double
    public var travelTimeSeconds: TimeInterval
    public var timestamp: Date
    
    public init(
        cacheKey: String,
        originLat: Double,
        originLon: Double,
        destLat: Double,
        destLon: Double,
        distanceMeters: Double,
        travelTimeSeconds: TimeInterval,
        timestamp: Date = Date()
    ) {
        self.cacheKey = cacheKey
        self.originLat = originLat
        self.originLon = originLon
        self.destLat = destLat
        self.destLon = destLon
        self.distanceMeters = distanceMeters
        self.travelTimeSeconds = travelTimeSeconds
        self.timestamp = timestamp
    }
}
