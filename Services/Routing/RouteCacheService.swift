import Foundation
import SwiftData

@MainActor
public final class RouteCacheService {
    private let modelContainer: ModelContainer
    private let maxAgeSeconds: TimeInterval
    
    public init(modelContainer: ModelContainer, maxAgeSeconds: TimeInterval = 86400) {
        self.modelContainer = modelContainer
        self.maxAgeSeconds = maxAgeSeconds
    }
    
    private func makeKey(origin: Coordinate, destination: Coordinate) -> String {
        let oLat = String(format: "%.4f", origin.latitude)
        let oLon = String(format: "%.4f", origin.longitude)
        let dLat = String(format: "%.4f", destination.latitude)
        let dLon = String(format: "%.4f", destination.longitude)
        return "\(oLat),\(oLon)->\(dLat),\(dLon)"
    }
    
    public func getCachedRoute(from origin: Coordinate, to destination: Coordinate) -> RouteSegmentResult? {
        let key = makeKey(origin: origin, destination: destination)
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<SDRouteCache>(predicate: #Predicate { $0.cacheKey == key })
        
        guard let cached = try? context.fetch(descriptor).first else { return nil }
        
        // Expiration check
        if Date().timeIntervalSince(cached.timestamp) > maxAgeSeconds {
            context.delete(cached)
            try? context.save()
            return nil
        }
        
        return RouteSegmentResult(
            origin: origin,
            destination: destination,
            distanceMeters: cached.distanceMeters,
            travelTimeSeconds: cached.travelTimeSeconds,
            polylinePoints: [origin, destination],
            isOffline: true
        )
    }
    
    public func saveRoute(_ segment: RouteSegmentResult) {
        let key = makeKey(origin: segment.origin, destination: segment.destination)
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<SDRouteCache>(predicate: #Predicate { $0.cacheKey == key })
        
        if let existing = try? context.fetch(descriptor).first {
            existing.distanceMeters = segment.distanceMeters
            existing.travelTimeSeconds = segment.travelTimeSeconds
            existing.timestamp = Date()
        } else {
            let entry = SDRouteCache(
                cacheKey: key,
                originLat: segment.origin.latitude,
                originLon: segment.origin.longitude,
                destLat: segment.destination.latitude,
                destLon: segment.destination.longitude,
                distanceMeters: segment.distanceMeters,
                travelTimeSeconds: segment.travelTimeSeconds
            )
            context.insert(entry)
        }
        try? context.save()
    }
}
