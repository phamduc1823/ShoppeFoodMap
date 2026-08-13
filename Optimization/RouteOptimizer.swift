import Foundation

/// Master VRPTW Route Optimizer engine.
public final class RouteOptimizer: RouteOptimizerProtocol, Sendable {
    private let routingService: RoutingServiceProtocol
    private let config: OptimizationConfiguration
    private let constraintChecker: RouteConstraintChecker
    private let riskCalculator: RiskCalculator
    private let scorer: RouteScorer
    
    public init(
        routingService: RoutingServiceProtocol,
        config: OptimizationConfiguration = .default
    ) {
        self.routingService = routingService
        self.config = config
        self.constraintChecker = RouteConstraintChecker()
        self.riskCalculator = RiskCalculator(config: config)
        self.scorer = RouteScorer(weights: config.weights)
    }
    
    public func optimize(
        orders: [Order],
        currentPosition: Coordinate,
        currentTime: Date
    ) async throws -> RouteCandidate {
        let activeOrders = constraintChecker.filterActiveOrders(orders)
        
        guard !activeOrders.isEmpty else {
            throw OptimizerError.emptyOrders
        }
        
        // 1. Build initial required stops for active orders
        var unvisitedStops = [RouteStop]()
        for order in activeOrders {
            if order.status == .pending || order.status == .accepted {
                // Needs both pickup and delivery
                let pStop = RouteStop(
                    orderId: order.id,
                    type: .pickup,
                    sequence: 0,
                    latitude: order.restaurantLatitude,
                    longitude: order.restaurantLongitude,
                    locationName: order.restaurantName,
                    pickupReadyAt: order.pickupReadyAt
                )
                let dStop = RouteStop(
                    orderId: order.id,
                    type: .delivery,
                    sequence: 0,
                    latitude: order.customerLatitude,
                    longitude: order.customerLongitude,
                    locationName: order.customerName,
                    deliveryWindowStart: order.deliveryWindowStart,
                    deliveryWindowEnd: order.deliveryWindowEnd
                )
                unvisitedStops.append(pStop)
                unvisitedStops.append(dStop)
            } else if order.status == .pickedUp {
                // Pickup already done, only delivery remaining
                let dStop = RouteStop(
                    orderId: order.id,
                    type: .delivery,
                    sequence: 0,
                    latitude: order.customerLatitude,
                    longitude: order.customerLongitude,
                    locationName: order.customerName,
                    deliveryWindowStart: order.deliveryWindowStart,
                    deliveryWindowEnd: order.deliveryWindowEnd
                )
                unvisitedStops.append(dStop)
            }
        }
        
        // 2. Pre-calculate distance matrix
        let matrixCalc = DistanceMatrixCalculator(routingService: routingService)
        let matrix = try await matrixCalc.buildMatrix(currentPosition: currentPosition, stops: unvisitedStops)
        
        // 3. Generate valid permutations
        let validSequences = generateValidStopSequences(stops: unvisitedStops)
        
        guard !validSequences.isEmpty else {
            throw OptimizerError.noFeasibleRouteFound
        }
        
        // 4. Evaluate each valid sequence
        var bestCandidate: RouteCandidate?
        var lowestScore: Double = .greatestFiniteMagnitude
        
        for sequence in validSequences {
            let candidate = evaluateSequence(
                sequence: sequence,
                currentPosition: currentPosition,
                currentTime: currentTime,
                matrix: matrix,
                orders: activeOrders
            )
            
            if candidate.score < lowestScore {
                lowestScore = candidate.score
                bestCandidate = candidate
            }
        }
        
        guard var result = bestCandidate else {
            throw OptimizerError.noFeasibleRouteFound
        }
        
        // Generate natural language explanation
        result.explanation = generateExplanation(candidate: result, totalOrders: activeOrders.count)
        return result
    }
    
    // MARK: - Sequence Generation & Permutations
    
    private func generateValidStopSequences(stops: [RouteStop]) -> [[RouteStop]] {
        var results = [[RouteStop]]()
        var currentSequence = [RouteStop]()
        var remainingStops = stops
        
        func backtrack() {
            if remainingStops.isEmpty {
                results.append(currentSequence)
                return
            }
            
            for i in 0..<remainingStops.count {
                let candidateStop = remainingStops[i]
                
                // Pruning constraint: Delivery cannot be added before Pickup
                if candidateStop.type == .delivery {
                    let hasPickupInUnvisited = remainingStops.contains { $0.orderId == candidateStop.orderId && $0.type == .pickup }
                    if hasPickupInUnvisited {
                        continue // Skip invalid branch!
                    }
                }
                
                let stop = remainingStops.remove(at: i)
                currentSequence.append(stop)
                
                backtrack()
                
                currentSequence.removeLast()
                remainingStops.insert(stop, at: i)
            }
        }
        
        backtrack()
        return results
    }
    
    // MARK: - Sequence Evaluation
    
    private func evaluateSequence(
        sequence: [RouteStop],
        currentPosition: Coordinate,
        currentTime: Date,
        matrix: [Coordinate: [Coordinate: RouteSegmentResult]],
        orders: [Order]
    ) -> RouteCandidate {
        var evaluatedStops = [RouteStop]()
        var simTime = currentTime
        var currentCoord = currentPosition
        var totalDist: Double = 0
        var totalTravelTime: TimeInterval = 0
        var totalWaitTime: TimeInterval = 0
        var isOffline = false
        
        for (idx, var stop) in sequence.enumerated() {
            stop.sequence = idx + 1
            
            let segment = matrix[currentCoord]?[stop.coordinate]
            let dist = segment?.distanceMeters ?? currentCoord.distance(to: stop.coordinate) * 1.35
            let travelSecs = segment?.travelTimeSeconds ?? (dist / config.defaultUrbanSpeedMetersPerSec * config.trafficMultiplier)
            if segment?.isOffline == true {
                isOffline = true
            }
            
            totalDist += dist
            totalTravelTime += travelSecs
            
            let arrivalTime = simTime.addingTimeInterval(travelSecs)
            stop.plannedArrival = arrivalTime
            
            var departureTime = arrivalTime
            if stop.type == .pickup, let readyAt = stop.pickupReadyAt, arrivalTime < readyAt {
                let waitSecs = readyAt.timeIntervalSince(arrivalTime)
                totalWaitTime += waitSecs
                departureTime = readyAt
            }
            
            stop.plannedDeparture = departureTime
            simTime = departureTime
            currentCoord = stop.coordinate
            evaluatedStops.append(stop)
        }
        
        let risk = riskCalculator.evaluateRisk(stops: evaluatedStops)
        let score = scorer.calculateScore(
            totalDistanceMeters: totalDist,
            totalTravelTimeSeconds: totalTravelTime,
            totalWaitingTimeSeconds: totalWaitTime,
            totalLatenessSeconds: risk.totalLatenessSeconds,
            risk: risk,
            orders: orders,
            currentTime: currentTime
        )
        
        return RouteCandidate(
            stops: evaluatedStops,
            totalDistanceMeters: totalDist,
            totalTravelTimeSeconds: totalTravelTime,
            totalWaitingTimeSeconds: totalWaitTime,
            totalLatenessSeconds: risk.totalLatenessSeconds,
            maximumLatenessSeconds: risk.maximumLatenessSeconds,
            minimumSlackSeconds: risk.minimumSlackSeconds,
            risk: risk,
            score: score,
            isOfflineEstimate: isOffline
        )
    }
    
    private func generateExplanation(candidate: RouteCandidate, totalOrders: Int) -> String {
        let distKm = String(format: "%.1f", candidate.totalDistanceKm)
        let riskName = candidate.risk.riskLevel.rawValue.uppercased()
        
        if candidate.risk.numberOfLateOrders > 0 {
            return "Recommended route (\(distKm) km) minimizes lateness to \(candidate.risk.numberOfLateOrders) order(s) under tight deadline constraints."
        } else if candidate.risk.riskLevel == .safe || candidate.risk.riskLevel == .low {
            return "Optimal route (\(distKm) km) satisfies all \(totalOrders) delivery time windows with low risk buffer (\(riskName))."
        } else {
            return "Recommended route prioritizes deadline reliability (\(riskName) risk), choosing a safer sequence over shortest distance."
        }
    }
}
