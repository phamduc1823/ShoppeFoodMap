import Foundation
import CoreLocation

/// Result of a routing query between two points.
public struct RouteSegmentResult: Codable, Equatable, Sendable {
    public let origin: Coordinate
    public let destination: Coordinate
    public let distanceMeters: Double
    public let travelTimeSeconds: TimeInterval
    public let polylinePoints: [Coordinate]
    public let isOffline: Bool
    
    public init(
        origin: Coordinate,
        destination: Coordinate,
        distanceMeters: Double,
        travelTimeSeconds: TimeInterval,
        polylinePoints: [Coordinate] = [],
        isOffline: Bool = false
    ) {
        self.origin = origin
        self.destination = destination
        self.distanceMeters = distanceMeters
        self.travelTimeSeconds = travelTimeSeconds
        self.polylinePoints = polylinePoints
        self.isOffline = isOffline
    }
}

/// Abstract protocol for routing and travel time providers.
public protocol RoutingServiceProtocol: Sendable {
    func calculateRoute(from origin: Coordinate, to destination: Coordinate) async throws -> RouteSegmentResult
    func calculateMatrix(origins: [Coordinate], destinations: [Coordinate]) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]]
}
