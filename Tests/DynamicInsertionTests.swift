import XCTest
import ShoppeFoodMap

final class DynamicInsertionTests: XCTestCase {
    var mockRouting: MockRoutingService!
    var optimizer: RouteOptimizer!
    var insertionOptimizer: DynamicInsertionOptimizer!
    let driverPosition = Coordinate(latitude: 21.0000, longitude: 105.8000)
    let baseTime = Date()
    
    override func setUp() {
        super.setUp()
        mockRouting = MockRoutingService()
        let config = OptimizationConfiguration.default
        optimizer = RouteOptimizer(routingService: mockRouting, config: config)
        insertionOptimizer = DynamicInsertionOptimizer(optimizer: optimizer)
    }
    
    func testSafeDynamicInsertion() async throws {
        let orderA = Order(
            orderNumber: "A101",
            createdAt: baseTime,
            restaurantName: "Rest A",
            restaurantLatitude: 21.0100,
            restaurantLongitude: 105.8100,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(1800),
            customerName: "Cust A",
            customerLatitude: 21.0200,
            customerLongitude: 105.8200,
            deliveryWindowStart: baseTime.addingTimeInterval(3600),
            deliveryWindowEnd: baseTime.addingTimeInterval(5400)
        )
        
        let baselineRoute = try await optimizer.optimize(
            orders: [orderA],
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        let newOrderB = Order(
            orderNumber: "B102",
            createdAt: baseTime,
            restaurantName: "Rest B",
            restaurantLatitude: 21.0150,
            restaurantLongitude: 105.8150,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(1800),
            customerName: "Cust B",
            customerLatitude: 21.0250,
            customerLongitude: 105.8250,
            deliveryWindowStart: baseTime.addingTimeInterval(3600),
            deliveryWindowEnd: baseTime.addingTimeInterval(5400)
        )
        
        let eval = try await insertionOptimizer.evaluateInsertion(
            newOrder: newOrderB,
            existingOrders: [orderA],
            currentRoute: baselineRoute,
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        XCTAssertEqual(eval.decision, InsertionDecision.safeToAdd)
        XCTAssertTrue(eval.explanation.contains("SAFE TO ADD"))
    }
    
    func testDynamicInsertionCausingLatenessRejected() async throws {
        // Order A has tight deadline
        let orderA = Order(
            orderNumber: "A_Tight",
            createdAt: baseTime,
            restaurantName: "Rest A",
            restaurantLatitude: 21.0100,
            restaurantLongitude: 105.8100,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(600),
            customerName: "Cust A",
            customerLatitude: 21.0200,
            customerLongitude: 105.8200,
            deliveryWindowStart: baseTime.addingTimeInterval(300),
            deliveryWindowEnd: baseTime.addingTimeInterval(600) // Tight 10 min deadline!
        )
        
        let baselineRoute = try await optimizer.optimize(
            orders: [orderA],
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        // Far away new Order B that would delay Order A
        let newOrderB = Order(
            orderNumber: "B_Far",
            createdAt: baseTime,
            restaurantName: "Rest B Far",
            restaurantLatitude: 21.2000,
            restaurantLongitude: 105.9500,
            pickupReadyAt: baseTime,
            pickupDeadline: baseTime.addingTimeInterval(1800),
            customerName: "Cust B Far",
            customerLatitude: 21.3000,
            customerLongitude: 105.9900,
            deliveryWindowStart: baseTime.addingTimeInterval(1800),
            deliveryWindowEnd: baseTime.addingTimeInterval(3600)
        )
        
        let eval = try await insertionOptimizer.evaluateInsertion(
            newOrder: newOrderB,
            existingOrders: [orderA],
            currentRoute: baselineRoute,
            currentPosition: driverPosition,
            currentTime: baseTime
        )
        
        XCTAssertEqual(eval.decision, InsertionDecision.doNotAdd)
        XCTAssertTrue(eval.explanation.contains("DO NOT ADD"))
    }
}
