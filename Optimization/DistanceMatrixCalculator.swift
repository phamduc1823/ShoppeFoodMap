import Foundation

/// Fast lookup matrix storing distance and travel time between coordinates.
public final class DistanceMatrixCalculator: Sendable {
    private let routingService: RoutingServiceProtocol
    
    public init(routingService: RoutingServiceProtocol) {
        self.routingService = routingService
    }
    
    /// Pre-calculates distance matrix between origin position and all stop locations.
    public func buildMatrix(
        currentPosition: Coordinate,
        stops: [RouteStop]
    ) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]] {
        var allPoints = Set<Coordinate>([currentPosition])
        for stop in stops {
            allPoints.insert(stop.coordinate)
        }
        let pointsArray = Array(allPoints)
        return try await routingService.calculateMatrix(origins: pointsArray, destinations: pointsArray)
    }
}
