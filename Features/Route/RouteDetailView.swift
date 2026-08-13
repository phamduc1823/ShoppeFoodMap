import SwiftUI

public struct RouteDetailView: View {
    public let candidate: RouteCandidate
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    public init(candidate: RouteCandidate) {
        self.candidate = candidate
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                VStack(spacing: 10) {
                    Text("ROUTE BREAKDOWN")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Total Distance")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f km", candidate.totalDistanceKm))
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Travel Time")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(candidate.totalTravelTimeMinutes)) min")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Wait Time")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(candidate.totalWaitingTimeSeconds / 60.0)) min")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Divider().background(AppTheme.cardBorder)
                    
                    HStack {
                        Text("Route Risk Level:")
                            .font(.subheadline)
                        Spacer()
                        RiskBadgeView(riskLevel: candidate.risk.riskLevel)
                    }
                }
                .padding(16)
                .glassmorphicCard()
                
                // Route Stops Sequence Detail
                VStack(alignment: .leading, spacing: 12) {
                    Text("STOP TIMELINE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    ForEach(candidate.stops) { stop in
                        HStack(alignment: .top, spacing: 12) {
                            Text(String(format: "%02d", stop.sequence))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(stop.type == .pickup ? AppTheme.primaryOrange : AppTheme.accentTeal)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(stop.type.displayName): \(stop.locationName)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                if let arr = stop.plannedArrival {
                                    Text("Planned Arrival: \(timeFormatter.string(from: arr))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if stop.type == .delivery, let windowEnd = stop.deliveryWindowEnd, let arrival = stop.plannedArrival {
                                    let slack = SlackTime(orderId: stop.orderId, estimatedArrival: arrival, deliveryDeadline: windowEnd)
                                    Text("Deadline \(timeFormatter.string(from: windowEnd)) (Slack: \(Int(slack.slackMinutes)) min)")
                                        .font(.caption2)
                                        .foregroundColor(AppTheme.color(forSlackRisk: slack.riskLevel))
                                }
                            }
                            Spacer()
                        }
                        .padding(12)
                        .glassmorphicCard()
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.backgroundDark.ignoresSafeArea())
        .navigationTitle("Route Details")
    }
}
