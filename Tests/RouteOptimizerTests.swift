import XCTest
import ShoppeFoodMap

final class RouteOptimizerTests: XCTestCase {
    var mockRouting: MockRoutingService!
    var optimizer: RouteOptimizer!
    let driverPosition = Coordinate(latitude: 21.0000, longitude: 105.8000)
    let baseTime = Date()
    
    override func setUp() {
        super.setUp()
        mockRouting = MockRoutingService()
        let config = OptimizationConfiguration.default
        optimizer = RouteOptimizer(routingService: mockRouting, config: config)
    }
    
    // Scenario 1: One Order
    func testSingleOrderOptimization() async throws {
        let order = Order(
            orderNumber: "A101",
            createdAt: baseTime,
            restaurantName: "Rest A",
            restaurantLatitude: 21.0100,
            restaurantLongitude: 105.8100,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(1200),
            customerName: "Cust A",
            customerLatitude: 21.0200,
            customerLongitude: 105.8200,
            deliveryWindowStart: baseTime.addingTimeInterval(1800),
            deliveryWindowEnd: baseTime.addingTimeInterval(2400)
        )
        
        let candidate = try await optimizer.optimize(
            orders: [order],
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        XCTAssertEqual(candidate.stops.count, 2)
        XCTAssertEqual(candidate.stops[0].type, StopType.pickup)
        XCTAssertEqual(candidate.stops[1].type, StopType.delivery)
        XCTAssertEqual(candidate.risk.numberOfLateOrders, 0)
    }
    
    // Scenario 5 & 6: Urgent Order vs Flexible Order (Reliability > Shortest Distance)
    func testEarlierDeadlinePrioritizedOverDistance() async throws {
        // Order A: Urgent deadline (4.5 mins). Going directly arrives in 3.4 mins (ON-TIME). Stopping at B causes lateness!
        let orderA = Order(
            orderNumber: "A_Tight",
            createdAt: baseTime,
            restaurantName: "Rest A Urgent",
            restaurantLatitude: 21.0100,
            restaurantLongitude: 105.8100,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(600),
            customerName: "Cust A",
            customerLatitude: 21.0150,
            customerLongitude: 105.8150,
            deliveryWindowStart: baseTime.addingTimeInterval(60),
            deliveryWindowEnd: baseTime.addingTimeInterval(270) // 4.5 min deadline!
        )
        
        // Order B: Closer to start, but flexible deadline (90 mins)
        let orderB = Order(
            orderNumber: "B_Flexible",
            createdAt: baseTime,
            restaurantName: "Rest B Close",
            restaurantLatitude: 21.0050,
            restaurantLongitude: 105.8050,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(3600),
            customerName: "Cust B",
            customerLatitude: 21.0080,
            customerLongitude: 105.8080,
            deliveryWindowStart: baseTime.addingTimeInterval(3600),
            deliveryWindowEnd: baseTime.addingTimeInterval(5400) // 90 min deadline
        )
        
        let candidate = try await optimizer.optimize(
            orders: [orderA, orderB],
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        XCTAssertEqual(candidate.stops.first?.orderId, orderA.id)
    }
    
    // Scenario 12: Restaurant Waiting Time Handling
    func testRestaurantWaitingTimeHandling() async throws {
        let delayedPickupTime = baseTime.addingTimeInterval(1200) // Ready in 20 mins
        let order = Order(
            orderNumber: "A_Wait",
            createdAt: baseTime,
            restaurantName: "Slow Rest",
            restaurantLatitude: 21.0050,
            restaurantLongitude: 105.8050,
            pickupReadyAt: delayedPickupTime,
            pickupDeadline: baseTime.addingTimeInterval(2400),
            customerName: "Cust A",
            customerLatitude: 21.0100,
            customerLongitude: 105.8100,
            deliveryWindowStart: baseTime.addingTimeInterval(1800),
            deliveryWindowEnd: baseTime.addingTimeInterval(3600)
        )
        
        let candidate = try await optimizer.optimize(
            orders: [order],
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        XCTAssertGreaterThan(candidate.totalWaitingTimeSeconds, 0)
    }
}
