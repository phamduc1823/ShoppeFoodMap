import Foundation
@preconcurrency import CoreLocation

/// Apple CLGeocoder implementation of GeocodingServiceProtocol.
public final class AppleGeocodingService: GeocodingServiceProtocol, @unchecked Sendable {
    private let geocoder = CLGeocoder()
    
    public init() {}
    
    public func geocodeAddress(_ address: String) async throws -> Coordinate {
        let placemarks = try await geocoder.geocodeAddressString(address)
        guard let location = placemarks.first?.location else {
            throw OptimizerError.geocodingFailed(address: address)
        }
        return Coordinate(location.coordinate)
    }
    
    public func reverseGeocode(coordinate: Coordinate) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            return "\(coordinate.latitude), \(coordinate.longitude)"
        }
        
        let components = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality
        ].compactMap { $0 }
        
        return components.isEmpty ? "\(coordinate.latitude), \(coordinate.longitude)" : components.joined(separator: ", ")
    }
}
