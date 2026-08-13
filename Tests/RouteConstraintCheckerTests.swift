import XCTest
import ShoppeFoodMap

final class RouteConstraintCheckerTests: XCTestCase {
    var constraintChecker: RouteConstraintChecker!
    let orderId = UUID()
    
    override func setUp() {
        super.setUp()
        constraintChecker = RouteConstraintChecker()
    }
    
    func testValidPickupBeforeDeliverySequence() {
        let pickup = RouteStop(orderId: orderId, type: .pickup, sequence: 1, latitude: 21.0, longitude: 105.0, locationName: "Rest")
        let delivery = RouteStop(orderId: orderId, type: .delivery, sequence: 2, latitude: 21.1, longitude: 105.1, locationName: "Cust")
        
        XCTAssertTrue(constraintChecker.isValidSequence([pickup, delivery]))
    }
    
    func testInvalidDeliveryBeforePickupSequence() {
        let pickup = RouteStop(orderId: orderId, type: .pickup, sequence: 2, latitude: 21.0, longitude: 105.0, locationName: "Rest")
        let delivery = RouteStop(orderId: orderId, type: .delivery, sequence: 1, latitude: 21.1, longitude: 105.1, locationName: "Cust")
        
        XCTAssertFalse(constraintChecker.isValidSequence([delivery, pickup]))
    }
}
