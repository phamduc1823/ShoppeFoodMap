import Foundation

/// Evaluates penalty score for candidate routes using configurable multi-objective weights.
public struct RouteScorer: Sendable {
    private let weights: RouteOptimizationWeights
    
    public init(weights: RouteOptimizationWeights = .default) {
        self.weights = weights
    }
    
    public func calculateScore(
        totalDistanceMeters: Double,
        totalTravelTimeSeconds: TimeInterval,
        totalWaitingTimeSeconds: TimeInterval,
        totalLatenessSeconds: TimeInterval,
        risk: RouteRisk,
        orders: [Order],
        currentTime: Date
    ) -> Double {
        let distKm = totalDistanceMeters / 1000.0
        let travelMin = totalTravelTimeSeconds / 60.0
        let waitMin = totalWaitingTimeSeconds / 60.0
        let lateMin = totalLatenessSeconds / 60.0
        
        let distPenalty = distKm * weights.distanceWeightPerKm
        let travelPenalty = travelMin * weights.travelTimeWeightPerMin
        let waitPenalty = waitMin * weights.waitingWeightPerMin
        
        // Non-linear lateness penalty: linear + quadratic term
        let latePenalty = (lateMin * weights.latenessWeightPerMinLinear) + (pow(lateMin, 2) * weights.latenessWeightPerMinQuadratic)
        
        // Risk penalty
        let riskPenaltyMultiplier: Double = {
            switch risk.riskLevel {
            case .safe: return 0.0
            case .low: return 1.0
            case .medium: return 3.0
            case .high: return 8.0
            case .critical: return 25.0
            }
        }()
        let riskPenalty = riskPenaltyMultiplier * weights.riskWeight
        
        // Order age penalty (starvation prevention)
        var agePenalty = 0.0
        for order in orders {
            let ageMin = max(0, currentTime.timeIntervalSince(order.createdAt) / 60.0)
            agePenalty += ageMin * weights.orderAgeWeightPerMin
        }
        
        return distPenalty + travelPenalty + waitPenalty + latePenalty + riskPenalty + agePenalty
    }
}
