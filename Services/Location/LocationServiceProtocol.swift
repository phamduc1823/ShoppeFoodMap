import Foundation
import CoreLocation

public protocol LocationServiceProtocol: AnyObject, Sendable {
    var currentLocation: Coordinate? { get }
    var locationPublisher: AsyncStream<Coordinate> { get }
    func requestPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func hasDeviatedSignificantly(fromPlannedRoutePlannedStops stops: [Coordinate], thresholdMeters: Double) -> Bool
}
