import XCTest

final class RouteScorerTests: XCTestCase {
    var scorer: RouteScorer!
    
    override func setUp() {
        super.setUp()
        scorer = RouteScorer(weights: .default)
    }
    
    func testLatenessPenaltyIsQuadraticAndHigh() {
        let riskSafe = RouteRisk(riskLevel: .safe)
        let scoreOnTime = scorer.calculateScore(
            totalDistanceMeters: 10000,
            totalTravelTimeSeconds: 600,
            totalWaitingTimeSeconds: 0,
            totalLatenessSeconds: 0,
            risk: riskSafe,
            orders: [],
            currentTime: Date()
        )
        
        let riskLate = RouteRisk(riskLevel: .critical, totalLatenessSeconds: 600) // 10 mins late
        let scoreLate = scorer.calculateScore(
            totalDistanceMeters: 10000,
            totalTravelTimeSeconds: 600,
            totalWaitingTimeSeconds: 0,
            totalLatenessSeconds: 600,
            risk: riskLate,
            orders: [],
            currentTime: Date()
        )
        
        // Late score must be significantly higher penalty than on-time score
        XCTAssertGreaterThan(scoreLate, scoreOnTime + 500)
    }
}
