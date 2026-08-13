import Foundation
import ShoppeFoodMap

public final class MockRoutingService: RoutingServiceProtocol, @unchecked Sendable {
    public var predefinedDistances: [Coordinate: [Coordinate: Double]] = [:]
    public var predefinedTravelTimes: [Coordinate: [Coordinate: TimeInterval]] = [:]
    public var defaultSpeedMetersPerSec: Double = 10.0 // 36 km/h
    public var isOffline: Bool = false
    
    public init() {}
    
    public func calculateRoute(from origin: Coordinate, to destination: Coordinate) async throws -> RouteSegmentResult {
        let dist = predefinedDistances[origin]?[destination] ?? origin.distance(to: destination) * 1.2
        let travelTime = predefinedTravelTimes[origin]?[destination] ?? (dist / defaultSpeedMetersPerSec)
        
        return RouteSegmentResult(
            origin: origin,
            destination: destination,
            distanceMeters: dist,
            travelTimeSeconds: travelTime,
            polylinePoints: [origin, destination],
            isOffline: isOffline
        )
    }
    
    public func calculateMatrix(origins: [Coordinate], destinations: [Coordinate]) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]] {
        var matrix: [Coordinate: [Coordinate: RouteSegmentResult]] = [:]
        for origin in origins {
            var map: [Coordinate: RouteSegmentResult] = [:]
            for dest in destinations {
                map[dest] = try await calculateRoute(from: origin, to: dest)
            }
            matrix[origin] = map
        }
        return matrix
    }
}
