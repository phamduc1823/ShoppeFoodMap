import Foundation
import SwiftUI
import MapKit

@Observable
public final class MapViewModel: @unchecked Sendable {
    public var currentRoute: RouteCandidate?
    public var driverLocation: Coordinate?
    
    private let locationService: LocationServiceProtocol
    
    public init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
        self.driverLocation = locationService.currentLocation ?? Coordinate(latitude: 21.0285, longitude: 105.8542)
    }
    
    public func updateRoute(_ route: RouteCandidate?) {
        self.currentRoute = route
    }
}
