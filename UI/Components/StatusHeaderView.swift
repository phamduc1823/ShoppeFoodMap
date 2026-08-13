import SwiftUI

public struct StatusHeaderView: View {
    public let isOnline: Bool
    public let activeOrdersCount: Int
    public let isLocating: Bool
    public let onRefresh: () -> Void
    
    public init(
        isOnline: Bool,
        activeOrdersCount: Int,
        isLocating: Bool,
        onRefresh: @escaping () -> Void
    ) {
        self.isOnline = isOnline
        self.activeOrdersCount = activeOrdersCount
        self.isLocating = isLocating
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        HStack {
            // Online / Offline Status Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(isOnline ? AppTheme.statusGreen : AppTheme.statusOrange)
                    .frame(width: 8, height: 8)
                Text(isOnline ? "ONLINE ROUTING" : "OFFLINE (ETA ESTIMATED)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isOnline ? AppTheme.statusGreen : AppTheme.statusOrange)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((isOnline ? AppTheme.statusGreen : AppTheme.statusOrange).opacity(0.15))
            .cornerRadius(12)
            
            Spacer()
            
            // GPS indicator
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(isLocating ? AppTheme.accentTeal : .secondary)
                Text(isLocating ? "GPS ACTIVE" : "NO GPS")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Refresh route button
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.primaryOrange)
                    .padding(6)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassmorphicCard()
    }
}
