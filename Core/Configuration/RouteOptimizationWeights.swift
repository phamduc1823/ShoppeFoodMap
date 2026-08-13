import Foundation

/// Configurable weights for route evaluation scoring penalty terms.
public struct RouteOptimizationWeights: Codable, Equatable, Sendable {
    /// Penalty coefficient per kilometer driven
    public var distanceWeightPerKm: Double
    
    /// Penalty coefficient per minute of travel time
    public var travelTimeWeightPerMin: Double
    
    /// Linear penalty coefficient per minute of lateness
    public var latenessWeightPerMinLinear: Double
    
    /// Quadratic penalty coefficient per minute of lateness (heavily penalizes long delays)
    public var latenessWeightPerMinQuadratic: Double
    
    /// Penalty coefficient per minute of driver idle waiting time at restaurants
    public var waitingWeightPerMin: Double
    
    /// Penalty coefficient per kilometer of extra detour
    public var detourWeightPerKm: Double
    
    /// Base penalty per risk level step above safe
    public var riskWeight: Double
    
    /// Penalty multiplier for older orders to prevent starvation
    public var orderAgeWeightPerMin: Double
    
    public init(
        distanceWeightPerKm: Double = 1.0,
        travelTimeWeightPerMin: Double = 0.5,
        latenessWeightPerMinLinear: Double = 50.0,
        latenessWeightPerMinQuadratic: Double = 10.0,
        waitingWeightPerMin: Double = 0.3,
        detourWeightPerKm: Double = 2.0,
        riskWeight: Double = 100.0,
        orderAgeWeightPerMin: Double = 0.2
    ) {
        self.distanceWeightPerKm = distanceWeightPerKm
        self.travelTimeWeightPerMin = travelTimeWeightPerMin
        self.latenessWeightPerMinLinear = latenessWeightPerMinLinear
        self.latenessWeightPerMinQuadratic = latenessWeightPerMinQuadratic
        self.waitingWeightPerMin = waitingWeightPerMin
        self.detourWeightPerKm = detourWeightPerKm
        self.riskWeight = riskWeight
        self.orderAgeWeightPerMin = orderAgeWeightPerMin
    }
    
    public static var `default`: RouteOptimizationWeights {
        RouteOptimizationWeights()
    }
}
