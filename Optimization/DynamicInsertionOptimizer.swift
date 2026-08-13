import Foundation

public enum InsertionDecision: String, Codable, CaseIterable, Sendable {
    case safeToAdd
    case addWithRisk
    case doNotAdd
    
    public var title: String {
        switch self {
        case .safeToAdd: return "SAFE TO ADD"
        case .addWithRisk: return "ADD WITH RISK"
        case .doNotAdd: return "DO NOT ADD"
        }
    }
    
    public var badgeColorName: String {
        switch self {
        case .safeToAdd: return "green"
        case .addWithRisk: return "yellow"
        case .doNotAdd: return "red"
        }
    }
}

public struct DynamicInsertionEvaluation: Sendable {
    public let decision: InsertionDecision
    public let newOrder: Order
    public let baselineRoute: RouteCandidate
    public let candidateRoute: RouteCandidate
    public let addedDistanceMeters: Double
    public let addedTravelTimeSeconds: TimeInterval
    public let explanation: String
    
    public var addedDistanceKm: Double {
        addedDistanceMeters / 1000.0
    }
    
    public var addedTravelTimeMinutes: Double {
        addedTravelTimeSeconds / 60.0
    }
}

/// Evaluates whether a newly received order can be safely inserted into the active route.
public struct DynamicInsertionOptimizer: Sendable {
    private let optimizer: RouteOptimizerProtocol
    
    public init(optimizer: RouteOptimizerProtocol) {
        self.optimizer = optimizer
    }
    
    public func evaluateInsertion(
        newOrder: Order,
        existingOrders: [Order],
        currentRoute: RouteCandidate,
        currentPosition: Coordinate,
        currentTime: Date
    ) async throws -> DynamicInsertionEvaluation {
        var combinedOrders = existingOrders.filter { $0.status.isActive }
        combinedOrders.append(newOrder)
        
        let candidateRoute = try await optimizer.optimize(
            orders: combinedOrders,
            currentPosition: currentPosition,
            currentTime: currentTime
        )
        
        let addedDist = max(0, candidateRoute.totalDistanceMeters - currentRoute.totalDistanceMeters)
        let addedTime = max(0, candidateRoute.totalTravelTimeSeconds - currentRoute.totalTravelTimeSeconds)
        
        // Analyze impact on existing orders
        let baselineLateCount = currentRoute.risk.numberOfLateOrders
        let candidateLateCount = candidateRoute.risk.numberOfLateOrders
        
        let decision: InsertionDecision
        let explanation: String
        
        if candidateLateCount > baselineLateCount || candidateRoute.risk.riskLevel == .critical {
            decision = .doNotAdd
            let newlyLateOrders = candidateRoute.risk.lateOrderIds.count
            explanation = "DO NOT ADD: Adding order #\(newOrder.orderNumber) adds \(String(format: "%.1f", addedDist/1000.0)) km and causes \(newlyLateOrders) order(s) to become late!"
        } else if candidateRoute.risk.riskLevel >= .high || (currentRoute.risk.riskLevel <= .low && candidateRoute.risk.riskLevel >= .medium) {
            decision = .addWithRisk
            explanation = "ADD WITH RISK: Order #\(newOrder.orderNumber) adds \(String(format: "%.1f", addedDist/1000.0)) km (+ \(Int(addedTime/60.0)) min) and reduces buffer time, raising route risk to \(candidateRoute.risk.riskLevel.rawValue.uppercased())."
        } else {
            decision = .safeToAdd
            explanation = "SAFE TO ADD: Order #\(newOrder.orderNumber) can be added safely (+ \(String(format: "%.1f", addedDist/1000.0)) km, + \(Int(addedTime/60.0)) min) while maintaining safe delivery windows."
        }
        
        return DynamicInsertionEvaluation(
            decision: decision,
            newOrder: newOrder,
            baselineRoute: currentRoute,
            candidateRoute: candidateRoute,
            addedDistanceMeters: addedDist,
            addedTravelTimeSeconds: addedTime,
            explanation: explanation
        )
    }
}
