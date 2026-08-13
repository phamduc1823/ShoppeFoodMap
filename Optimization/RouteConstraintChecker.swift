import Foundation

/// Validates whether a candidate stop sequence obeys all business and feasibility constraints.
public struct RouteConstraintChecker: Sendable {
    public init() {}
    
    /// Checks if a proposed sequence of RouteStops satisfies all precedence constraints.
    public func isValidSequence(_ stops: [RouteStop]) -> Bool {
        var pickedUpOrderIds = Set<UUID>()
        
        for stop in stops {
            switch stop.type {
            case .pickup:
                pickedUpOrderIds.insert(stop.orderId)
            case .delivery:
                // Delivery cannot occur before pickup
                if !pickedUpOrderIds.contains(stop.orderId) {
                    return false
                }
            }
        }
        return true
    }
    
    /// Filters active orders to exclude completed or cancelled orders.
    public func filterActiveOrders(_ orders: [Order]) -> [Order] {
        orders.filter { $0.status.isActive }
    }
}
