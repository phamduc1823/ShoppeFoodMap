import Foundation

/// Pure local offline fallback routing service using Haversine distance and configurable speed models.
public final class OfflineFallbackRoutingService: RoutingServiceProtocol {
    private let speedMetersPerSec: Double
    private let trafficMultiplier: Double
    
    public init(speedMetersPerSec: Double = 7.78, trafficMultiplier: Double = 1.25) {
        self.speedMetersPerSec = speedMetersPerSec
        self.trafficMultiplier = trafficMultiplier
    }
    
    public func calculateRoute(from origin: Coordinate, to destination: Coordinate) async throws -> RouteSegmentResult {
        let straightLineMeters = origin.distance(to: destination)
        // Urban road winding factor (manhattan distance / road winding ratio ~ 1.35)
        let estimatedRoadMeters = straightLineMeters * 1.35
        let baseTimeSecs = estimatedRoadMeters / speedMetersPerSec
        let totalTravelTimeSecs = baseTimeSecs * trafficMultiplier
        
        return RouteSegmentResult(
            origin: origin,
            destination: destination,
            distanceMeters: estimatedRoadMeters,
            travelTimeSeconds: max(30.0, totalTravelTimeSecs),
            polylinePoints: [origin, destination],
            isOffline: true
        )
    }
    
    public func calculateMatrix(origins: [Coordinate], destinations: [Coordinate]) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]] {
        var matrix: [Coordinate: [Coordinate: RouteSegmentResult]] = [:]
        for origin in origins {
            var destMap: [Coordinate: RouteSegmentResult] = [:]
            for dest in destinations {
                destMap[dest] = try await calculateRoute(from: origin, to: dest)
            }
            matrix[origin] = destMap
        }
        return matrix
    }
}
