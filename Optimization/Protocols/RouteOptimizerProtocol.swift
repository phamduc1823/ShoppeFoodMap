import Foundation

public protocol RouteOptimizerProtocol: Sendable {
    func optimize(
        orders: [Order],
        currentPosition: Coordinate,
        currentTime: Date
    ) async throws -> RouteCandidate
}
