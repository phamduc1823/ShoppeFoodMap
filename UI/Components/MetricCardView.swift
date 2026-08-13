import SwiftUI

public struct MetricCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let iconName: String
    public let iconColor: Color
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconName: String,
        iconColor: Color = AppTheme.primaryOrange
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconColor = iconColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.subheadline)
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassmorphicCard()
    }
}
