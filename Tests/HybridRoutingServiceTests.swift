import XCTest
import ShoppeFoodMap

final class HybridRoutingServiceTests: XCTestCase {
    func testOfflineFallbackRouting() async throws {
        let fallbackService = OfflineFallbackRoutingService()
        let origin = Coordinate(latitude: 21.0000, longitude: 105.8000)
        let destination = Coordinate(latitude: 21.0100, longitude: 105.8100)
        
        let result = try await fallbackService.calculateRoute(from: origin, to: destination)
        
        XCTAssertTrue(result.isOffline)
        XCTAssertGreaterThan(result.distanceMeters, 0)
        XCTAssertGreaterThan(result.travelTimeSeconds, 0)
    }
}
