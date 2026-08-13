import SwiftUI

public struct OrderCardView: View {
    public let order: Order
    public let onSelect: () -> Void
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(order.orderNumber)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryOrange)
                
                Spacer()
                
                Text(order.status.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.accentTeal.opacity(0.2))
                    .foregroundColor(AppTheme.accentTeal)
                    .cornerRadius(6)
            }
            
            Divider()
                .background(AppTheme.cardBorder)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppTheme.primaryOrange)
                    Text("Pickup: \(order.restaurantName)")
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(AppTheme.accentTeal)
                    Text("Deliver: \(order.customerName)")
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            
            HStack {
                Text("Window: \(timeFormatter.string(from: order.deliveryWindowStart)) - \(timeFormatter.string(from: order.deliveryWindowEnd))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onSelect) {
                    Text("Details")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primaryOrange)
                }
            }
        }
        .padding(12)
        .glassmorphicCard()
    }
}
