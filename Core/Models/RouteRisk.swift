import Foundation

/// Overall risk level of a candidate route.
public enum RouteRiskLevel: String, Codable, CaseIterable, Comparable, Sendable {
    case safe
    case low
    case medium
    case high
    case critical
    
    private var severityOrder: Int {
        switch self {
        case .safe: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
    
    public static func < (lhs: RouteRiskLevel, rhs: RouteRiskLevel) -> Bool {
        lhs.severityOrder < rhs.severityOrder
    }
    
    public var badgeColorName: String {
        switch self {
        case .safe: return "green"
        case .low: return "mint"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

/// Detailed evaluation of route risk metrics.
public struct RouteRisk: Codable, Equatable, Hashable, Sendable {
    public let riskLevel: RouteRiskLevel
    public let totalLatenessSeconds: TimeInterval
    public let maximumLatenessSeconds: TimeInterval
    public let minimumSlackSeconds: TimeInterval
    public let numberOfLateOrders: Int
    public let numberOfAtRiskOrders: Int
    public let lateOrderIds: [UUID]
    public let atRiskOrderIds: [UUID]
    
    public init(
        riskLevel: RouteRiskLevel,
        totalLatenessSeconds: TimeInterval = 0,
        maximumLatenessSeconds: TimeInterval = 0,
        minimumSlackSeconds: TimeInterval = .greatestFiniteMagnitude,
        numberOfLateOrders: Int = 0,
        numberOfAtRiskOrders: Int = 0,
        lateOrderIds: [UUID] = [],
        atRiskOrderIds: [UUID] = []
    ) {
        self.riskLevel = riskLevel
        self.totalLatenessSeconds = totalLatenessSeconds
        self.maximumLatenessSeconds = maximumLatenessSeconds
        self.minimumSlackSeconds = minimumSlackSeconds
        self.numberOfLateOrders = numberOfLateOrders
        self.numberOfAtRiskOrders = numberOfAtRiskOrders
        self.lateOrderIds = lateOrderIds
        self.atRiskOrderIds = atRiskOrderIds
    }
}
