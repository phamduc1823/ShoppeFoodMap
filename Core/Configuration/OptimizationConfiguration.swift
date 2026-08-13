import Foundation

/// Master configuration for the VRPTW route optimization engine.
public struct OptimizationConfiguration: Codable, Equatable, Sendable {
    public var weights: RouteOptimizationWeights
    
    // Buffer thresholds in minutes
    public var criticalSlackMinutesThreshold: Double // < 0 mins
    public var highSlackMinutesThreshold: Double     // < 5 mins
    public var mediumSlackMinutesThreshold: Double   // < 15 mins
    public var lowSlackMinutesThreshold: Double      // < 30 mins
    
    // Offline fallback urban travel speed assumptions (meters per second)
    public var defaultUrbanSpeedMetersPerSec: Double // ~28 km/h = 7.78 m/s
    public var trafficMultiplier: Double             // 1.25x factor for urban traffic
    
    // Maximum active orders for brute force vs heuristic search
    public var maxBruteForceOrdersCount: Int
    
    // Movement threshold to trigger automatic route recalculation (meters)
    public var rerouteDistanceThresholdMeters: Double
    
    public init(
        weights: RouteOptimizationWeights = .default,
        criticalSlackMinutesThreshold: Double = 0.0,
        highSlackMinutesThreshold: Double = 5.0,
        mediumSlackMinutesThreshold: Double = 15.0,
        lowSlackMinutesThreshold: Double = 30.0,
        defaultUrbanSpeedMetersPerSec: Double = 7.78,
        trafficMultiplier: Double = 1.25,
        maxBruteForceOrdersCount: Int = 4,
        rerouteDistanceThresholdMeters: Double = 150.0
    ) {
        self.weights = weights
        self.criticalSlackMinutesThreshold = criticalSlackMinutesThreshold
        self.highSlackMinutesThreshold = highSlackMinutesThreshold
        self.mediumSlackMinutesThreshold = mediumSlackMinutesThreshold
        self.lowSlackMinutesThreshold = lowSlackMinutesThreshold
        self.defaultUrbanSpeedMetersPerSec = defaultUrbanSpeedMetersPerSec
        self.trafficMultiplier = trafficMultiplier
        self.maxBruteForceOrdersCount = maxBruteForceOrdersCount
        self.rerouteDistanceThresholdMeters = rerouteDistanceThresholdMeters
    }
    
    public static var `default`: OptimizationConfiguration {
        OptimizationConfiguration()
    }
}
