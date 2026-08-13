import Foundation

/// Risk classification for an individual delivery stop based on slack time buffer.
public enum SlackRiskLevel: String, Codable, CaseIterable, Comparable, Sendable {
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
    
    public static func < (lhs: SlackRiskLevel, rhs: SlackRiskLevel) -> Bool {
        lhs.severityOrder < rhs.severityOrder
    }
}

/// Representation of slack time buffer at a delivery stop.
public struct SlackTime: Codable, Equatable, Hashable, Sendable {
    public let orderId: UUID
    public let estimatedArrival: Date
    public let deliveryDeadline: Date
    /// Slack time in seconds: deliveryDeadline - estimatedArrival
    public let slackSeconds: TimeInterval
    
    public var slackMinutes: Double {
        slackSeconds / 60.0
    }
    
    public var riskLevel: SlackRiskLevel {
        if slackSeconds < 0 {
            return .critical
        } else if slackMinutes < 5.0 {
            return .high
        } else if slackMinutes < 15.0 {
            return .medium
        } else if slackMinutes < 30.0 {
            return .low
        } else {
            return .safe
        }
    }
    
    public init(orderId: UUID, estimatedArrival: Date, deliveryDeadline: Date) {
        self.orderId = orderId
        self.estimatedArrival = estimatedArrival
        self.deliveryDeadline = deliveryDeadline
        self.slackSeconds = deliveryDeadline.timeIntervalSince(estimatedArrival)
    }
}
