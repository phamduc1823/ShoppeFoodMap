import Foundation

/// Type of route stop (pickup at restaurant or delivery to customer).
public enum StopType: String, Codable, CaseIterable, Sendable {
    case pickup
    case delivery
    
    public var displayName: String {
        switch self {
        case .pickup: return "PICKUP"
        case .delivery: return "DELIVERY"
        }
    }
}
