import Foundation

public enum OptimizerError: LocalizedError, Equatable {
    case emptyOrders
    case noFeasibleRouteFound
    case invalidOrderSequence(reason: String)
    case routingServiceFailed(reason: String)
    case geocodingFailed(address: String)
    case orderNotFound(id: UUID)
    
    public var errorDescription: String? {
        switch self {
        case .emptyOrders:
            return "No active orders provided for route optimization."
        case .noFeasibleRouteFound:
            return "Unable to calculate a valid route satisfying hard constraints."
        case .invalidOrderSequence(let reason):
            return "Invalid order sequence constraint: \(reason)"
        case .routingServiceFailed(let reason):
            return "Routing service failed: \(reason)"
        case .geocodingFailed(let address):
            return "Failed to resolve coordinates for address: \(address)"
        case .orderNotFound(let id):
            return "Order with ID \(id) was not found."
        }
    }
}
