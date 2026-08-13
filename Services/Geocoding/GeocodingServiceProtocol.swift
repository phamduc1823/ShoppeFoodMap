import Foundation
import CoreLocation

public protocol GeocodingServiceProtocol: Sendable {
    func geocodeAddress(_ address: String) async throws -> Coordinate
    func reverseGeocode(coordinate: Coordinate) async throws -> String
}
