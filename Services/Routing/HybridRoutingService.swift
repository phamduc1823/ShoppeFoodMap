import Foundation

/// Orchestrator routing service implementing online-first routing with local cache & offline fallback.
public final class HybridRoutingService: RoutingServiceProtocol {
    private let onlineService: RoutingServiceProtocol
    private let offlineFallbackService: RoutingServiceProtocol
    private let cacheService: RouteCacheService?
    private let networkMonitor: NetworkMonitor
    
    public init(
        onlineService: RoutingServiceProtocol = AppleRoutingService(),
        offlineFallbackService: RoutingServiceProtocol = OfflineFallbackRoutingService(),
        cacheService: RouteCacheService? = nil,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.onlineService = onlineService
        self.offlineFallbackService = offlineFallbackService
        self.cacheService = cacheService
        self.networkMonitor = networkMonitor
    }
    
    public func calculateRoute(from origin: Coordinate, to destination: Coordinate) async throws -> RouteSegmentResult {
        if origin == destination {
            return RouteSegmentResult(origin: origin, destination: destination, distanceMeters: 0, travelTimeSeconds: 0, polylinePoints: [origin], isOffline: false)
        }
        
        // 1. If connected, attempt online routing
        if networkMonitor.isConnected {
            do {
                let onlineResult = try await onlineService.calculateRoute(from: origin, to: destination)
                // Cache successful result asynchronously on main thread
                Task { @MainActor in
                    self.cacheService?.saveRoute(onlineResult)
                }
                return onlineResult
            } catch {
                // Fallback to cache/offline on online failure
            }
        }
        
        // 2. Offline / network failure: Check local cache first
        if let cacheService = cacheService {
            let cachedResult = await Task { @MainActor in
                cacheService.getCachedRoute(from: origin, to: destination)
            }.value
            
            if let cached = cachedResult {
                return cached
            }
        }
        
        // 3. Cache miss offline: Use mathematical offline speed model
        return try await offlineFallbackRoutingService.calculateRoute(from: origin, to: destination)
    }
    
    private var offlineFallbackRoutingService: RoutingServiceProtocol {
        offlineFallbackService
    }
    
    public func calculateMatrix(origins: [Coordinate], destinations: [Coordinate]) async throws -> [Coordinate: [Coordinate: RouteSegmentResult]] {
        var matrix: [Coordinate: [Coordinate: RouteSegmentResult]] = [:]
        for origin in origins {
            var destMap: [Coordinate: RouteSegmentResult] = [:]
            for dest in destinations {
                destMap[dest] = try await calculateRoute(from: origin, to: dest)
            }
            matrix[origin] = destMap
        }
        return matrix
    }
}
