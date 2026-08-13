import Foundation

/// Status lifecycle for a food delivery order.
public enum OrderStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case accepted
    case pickedUp
    case delivered
    case cancelled
    
    public var isCompleted: Bool {
        self == .delivered || self == .cancelled
    }
    
    public var isActive: Bool {
        self == .pending || self == .accepted || self == .pickedUp
    }
}
