import Foundation

/// Evaluates slack buffer times and classifies overall route risk.
public struct RiskCalculator: Sendable {
    private let config: OptimizationConfiguration
    
    public init(config: OptimizationConfiguration = .default) {
        self.config = config
    }
    
    public func evaluateRisk(stops: [RouteStop]) -> RouteRisk {
        var totalLateness: TimeInterval = 0
        var maxLateness: TimeInterval = 0
        var minSlack: TimeInterval = .greatestFiniteMagnitude
        var lateCount = 0
        var atRiskCount = 0
        var lateOrderIds = [UUID]()
        var atRiskOrderIds = [UUID]()
        var highestSeverity: RouteRiskLevel = .safe
        
        for stop in stops where stop.type == .delivery {
            guard let arrival = stop.plannedArrival, let windowEnd = stop.deliveryWindowEnd else { continue }
            
            let slackTime = SlackTime(orderId: stop.orderId, estimatedArrival: arrival, deliveryDeadline: windowEnd)
            let slackSecs = slackTime.slackSeconds
            let latenessSecs = max(0, -slackSecs)
            
            if latenessSecs > 0 {
                totalLateness += latenessSecs
                maxLateness = max(maxLateness, latenessSecs)
                lateCount += 1
                lateOrderIds.append(stop.orderId)
            }
            
            minSlack = min(minSlack, slackSecs)
            
            let stopRisk = slackTime.riskLevel
            if stopRisk >= .medium {
                atRiskCount += 1
                atRiskOrderIds.append(stop.orderId)
            }
            
            // Map SlackRiskLevel to RouteRiskLevel
            let routeRiskLevel: RouteRiskLevel = {
                switch stopRisk {
                case .safe: return .safe
                case .low: return .low
                case .medium: return .medium
                case .high: return .high
                case .critical: return .critical
                }
            }()
            
            if routeRiskLevel > highestSeverity {
                highestSeverity = routeRiskLevel
            }
        }
        
        return RouteRisk(
            riskLevel: highestSeverity,
            totalLatenessSeconds: totalLateness,
            maximumLatenessSeconds: maxLateness,
            minimumSlackSeconds: minSlack == .greatestFiniteMagnitude ? 0 : minSlack,
            numberOfLateOrders: lateCount,
            numberOfAtRiskOrders: atRiskCount,
            lateOrderIds: lateOrderIds,
            atRiskOrderIds: atRiskOrderIds
        )
    }
}
