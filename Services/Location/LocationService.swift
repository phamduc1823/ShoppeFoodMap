import Foundation
import CoreLocation
import Combine

@Observable
public final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol, @unchecked Sendable {
    public private(set) var currentLocation: Coordinate?
    public private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager: CLLocationManager
    private var streamContinuation: AsyncStream<Coordinate>.Continuation?
    
    public var locationPublisher: AsyncStream<Coordinate> {
        AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }
    
    public init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 15.0 // Notify when moved at least 15 meters
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Allow setting simulated coordinate for testing or static demonstration.
    public func setSimulatedLocation(_ coordinate: Coordinate) {
        self.currentLocation = coordinate
        streamContinuation?.yield(coordinate)
    }
    
    public func hasDeviatedSignificantly(fromPlannedRoutePlannedStops stops: [Coordinate], thresholdMeters: Double = 150.0) -> Bool {
        guard let current = currentLocation, !stops.isEmpty else { return false }
        let minDistance = stops.map { current.distance(to: $0) }.min() ?? 0
        return minDistance > thresholdMeters
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        let coord = Coordinate(lastLocation.coordinate)
        DispatchQueue.main.async {
            self.currentLocation = coord
            self.streamContinuation?.yield(coord)
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed: \(error.localizedDescription)")
    }
}
