import Foundation

/// Evaluated candidate route containing planned stop sequence and calculated metrics.
public struct RouteCandidate: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var stops: [RouteStop]
    public var totalDistanceMeters: Double
    public var totalTravelTimeSeconds: TimeInterval
    public var totalWaitingTimeSeconds: TimeInterval
    public var totalLatenessSeconds: TimeInterval
    public var maximumLatenessSeconds: TimeInterval
    public var minimumSlackSeconds: TimeInterval
    public var risk: RouteRisk
    public var score: Double
    public var explanation: String
    public var isOfflineEstimate: Bool
    
    public var totalDistanceKm: Double {
        totalDistanceMeters / 1000.0
    }
    
    public var totalTravelTimeMinutes: Double {
        totalTravelTimeSeconds / 60.0
    }
    
    public var estimatedCompletionTime: Date? {
        stops.last?.plannedArrival
    }
    
    public init(
        id: UUID = UUID(),
        stops: [RouteStop],
        totalDistanceMeters: Double,
        totalTravelTimeSeconds: TimeInterval,
        totalWaitingTimeSeconds: TimeInterval = 0,
        totalLatenessSeconds: TimeInterval = 0,
        maximumLatenessSeconds: TimeInterval = 0,
        minimumSlackSeconds: TimeInterval = .greatestFiniteMagnitude,
        risk: RouteRisk,
        score: Double,
        explanation: String = "",
        isOfflineEstimate: Bool = false
    ) {
        self.id = id
        self.stops = stops
        self.totalDistanceMeters = totalDistanceMeters
        self.totalTravelTimeSeconds = totalTravelTimeSeconds
        self.totalWaitingTimeSeconds = totalWaitingTimeSeconds
        self.totalLatenessSeconds = totalLatenessSeconds
        self.maximumLatenessSeconds = maximumLatenessSeconds
        self.minimumSlackSeconds = minimumSlackSeconds
        self.risk = risk
        self.score = score
        self.explanation = explanation
        self.isOfflineEstimate = isOfflineEstimate
    }
}
