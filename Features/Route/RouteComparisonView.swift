import SwiftUI

public struct RouteComparisonView: View {
    public let routeA: RouteCandidate
    public let routeB: RouteCandidate
    public let recommendationReason: String
    
    public init(routeA: RouteCandidate, routeB: RouteCandidate, recommendationReason: String) {
        self.routeA = routeA
        self.routeB = routeB
        self.recommendationReason = recommendationReason
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Recommendation Banner
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppTheme.statusYellow)
                    Text(recommendationReason)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .padding(16)
                .glassmorphicCard()
                
                // Side-by-side Comparison Cards
                HStack(spacing: 12) {
                    // Route A Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ROUTE A (RECOMMENDED)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.statusGreen)
                        
                        Text(String(format: "%.1f km", routeA.totalDistanceKm))
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("ETA: \(Int(routeA.totalTravelTimeMinutes)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RiskBadgeView(riskLevel: routeA.risk.riskLevel)
                    }
                    .padding(14)
                    .glassmorphicCard()
                    
                    // Route B Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ROUTE B (SHORTER)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f km", routeB.totalDistanceKm))
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("ETA: \(Int(routeB.totalTravelTimeMinutes)) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        RiskBadgeView(riskLevel: routeB.risk.riskLevel)
                    }
                    .padding(14)
                    .glassmorphicCard()
                }
            }
            .padding(16)
        }
        .background(AppTheme.backgroundDark.ignoresSafeArea())
        .navigationTitle("Route Comparison")
    }
}
