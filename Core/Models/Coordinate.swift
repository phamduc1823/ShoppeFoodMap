import Foundation
import CoreLocation

/// Structure representing a geographical coordinate.
public struct Coordinate: Codable, Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init(_ clCoordinate: CLLocationCoordinate2D) {
        self.latitude = clCoordinate.latitude
        self.longitude = clCoordinate.longitude
    }
    
    public var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Calculate straight-line Haversine distance in meters to another coordinate.
    public func distance(to destination: Coordinate) -> Double {
        let locA = CLLocation(latitude: latitude, longitude: longitude)
        let locB = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return locA.distance(from: locB)
    }
}
