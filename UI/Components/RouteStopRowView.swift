import SwiftUI

public struct RouteStopRowView: View {
    public let stop: RouteStop
    public let onCompleteStop: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Sequence Badge
            ZStack {
                Circle()
                    .fill(stop.type == .pickup ? AppTheme.primaryOrange : AppTheme.accentTeal)
                    .frame(width: 36, height: 36)
                Text(String(format: "%02d", stop.sequence))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Location & Detail Information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(stop.type.displayName)
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((stop.type == .pickup ? AppTheme.primaryOrange : AppTheme.accentTeal).opacity(0.2))
                        .foregroundColor(stop.type == .pickup ? AppTheme.primaryOrange : AppTheme.accentTeal)
                        .cornerRadius(4)
                    
                    Text(stop.locationName)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    if let eta = stop.plannedArrival {
                        Text("ETA \(dateFormatter.string(from: eta))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if stop.type == .delivery, let start = stop.deliveryWindowStart, let end = stop.deliveryWindowEnd {
                        Text("Window \(dateFormatter.string(from: start))-\(dateFormatter.string(from: end))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Buffer / Slack Time
                if stop.type == .delivery, let arrival = stop.plannedArrival, let windowEnd = stop.deliveryWindowEnd {
                    let slack = SlackTime(orderId: stop.orderId, estimatedArrival: arrival, deliveryDeadline: windowEnd)
                    HStack(spacing: 4) {
                        Text(slack.slackSeconds >= 0 ? "Buffer +\(Int(slack.slackMinutes)) min" : "LATE \(Int(abs(slack.slackMinutes))) min!")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.color(forSlackRisk: slack.riskLevel))
                    }
                }
            }
            
            Spacer()
            
            // Complete Action Button
            Button(action: onCompleteStop) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.statusGreen)
            }
        }
        .padding(12)
        .glassmorphicCard()
    }
}
