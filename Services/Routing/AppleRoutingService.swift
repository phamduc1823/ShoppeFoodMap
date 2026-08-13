import Foundation
import MapKit

/// Online routing service backed by MapKit MKDirections API.
public final class AppleRoutingService: RoutingServiceProtocol {
    public init() {}
    
    public func calculateRoute(from origin: Coordinate, to destination: Coordinate) async throws -> RouteSegmentResult {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin.clCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.clCoordinate))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            guard let route = response.routes.first else {
                throw OptimizerError.routingServiceFailed(reason: "No route returned by MapKit.")
            }
            
            // Extract polyline points
            var polylineCoords = [Coordinate]()
            let pointCount = route.polyline.pointCount
            if pointCount > 0 {
                var coords = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: pointCount)
                route.polyline.getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
                polylineCoords = coords.map { Coordinate($0) }
            } else {
                polylineCoords = [origin, destination]
            }
            
            return RouteSegmentResult(
                origin: origin,
                destination: destination,
                distanceMeters: route.distance,
                travelTimeSeconds: route.expectedTravelTime,
                polylinePoints: polylineCoords,
                isOffline: false
            )
        } catch {
            throw OptimizerError.routingServiceFailed(reason: error.localizedDescription)
        }
    }
    
    public func calculateMatrix(origins: [Coordinate], destinations: [Coordinate]) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]] {
        var matrix: [Coordinate: [Coordinate: RouteSegmentResult]] = [:]
        for origin in origins {
            var destMap: [Coordinate: RouteSegmentResult] = [:]
            for dest in destinations {
                if origin == dest {
                    destMap[dest] = RouteSegmentResult(origin: origin, destination: dest, distanceMeters: 0, travelTimeSeconds: 0, polylinePoints: [origin], isOffline: false)
                } else {
                    destMap[dest] = try await calculateRoute(from: origin, to: dest)
                }
            }
            matrix[origin] = destMap
        }
        return matrix
    }
}
