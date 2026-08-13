import Foundation

public protocol OrderRepositoryProtocol: Sendable {
    func fetchAllOrders() async throws -> [Order]
    func fetchActiveOrders() async throws -> [Order]
    func fetchOrder(id: UUID) async throws -> Order?
    func saveOrder(_ order: Order) async throws
    func updateOrderStatus(id: UUID, status: OrderStatus) async throws
    func deleteOrder(id: UUID) async throws
    func recordAnalytics(entry: SDAnalyticsEntry) async throws
}
