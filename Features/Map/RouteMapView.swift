import SwiftUI
import MapKit

public struct RouteMapView: View {
    @Bindable var viewModel: MapViewModel
    
    public init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Map {
                // Driver Location Marker
                if let driver = viewModel.driverLocation {
                    Annotation("Driver Position", coordinate: driver.clCoordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 28, height: 28)
                            Image(systemName: "location.north.fill")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .shadow(radius: 4)
                    }
                }
                
                // Route Stop Markers
                if let route = viewModel.currentRoute {
                    ForEach(route.stops) { stop in
                        Annotation(stop.locationName, coordinate: stop.coordinate.clCoordinate) {
                            ZStack {
                                Circle()
                                    .fill(stop.type == .pickup ? AppTheme.primaryOrange : AppTheme.accentTeal)
                                    .frame(width: 32, height: 32)
                                Text("\(stop.sequence)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .shadow(radius: 4)
                        }
                    }
                    
                    // Simple Route Polyline Overlay connecting stops
                    let polylineCoords = buildPolylineCoordinates(route: route)
                    MapPolyline(coordinates: polylineCoords)
                        .stroke(AppTheme.primaryOrange, lineWidth: 4)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            
            // Map Overlay Header Summary
            VStack {
                if let route = viewModel.currentRoute {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ACTIVE ROUTE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", route.totalDistanceKm)) km • \(Int(route.totalTravelTimeMinutes)) min")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        RiskBadgeView(riskLevel: route.risk.riskLevel)
                    }
                    .padding(12)
                    .glassmorphicCard()
                    .padding(16)
                }
                Spacer()
            }
        }
    }
    
    private func buildPolylineCoordinates(route: RouteCandidate) -> [CLLocationCoordinate2D] {
        var result = [CLLocationCoordinate2D]()
        if let driver = viewModel.driverLocation {
            result.append(driver.clCoordinate)
        }
        for stop in route.stops {
            result.append(stop.coordinate.clCoordinate)
        }
        return result
    }
}
