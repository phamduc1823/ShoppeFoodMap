import SwiftUI

public struct RiskBadgeView: View {
    public let riskLevel: RouteRiskLevel
    
    public init(riskLevel: RouteRiskLevel) {
        self.riskLevel = riskLevel
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(AppTheme.color(forRisk: riskLevel))
                .frame(width: 8, height: 8)
            Text(riskLevel.rawValue.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.color(forRisk: riskLevel))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(AppTheme.color(forRisk: riskLevel).opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.color(forRisk: riskLevel).opacity(0.4), lineWidth: 1)
        )
    }
}
