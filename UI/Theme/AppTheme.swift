import SwiftUI

public enum AppTheme {
    // Curated Harmonious Color Palette
    public static let primaryOrange = Color(red: 0.98, green: 0.38, blue: 0.12)
    public static let accentTeal = Color(red: 0.08, green: 0.72, blue: 0.65)
    public static let backgroundDark = Color(red: 0.07, green: 0.09, blue: 0.12)
    public static let cardBackground = Color(red: 0.12, green: 0.15, blue: 0.20)
    public static let cardBorder = Color(red: 0.20, green: 0.25, blue: 0.32)
    
    // Status Colors
    public static let statusGreen = Color(red: 0.15, green: 0.78, blue: 0.42)
    public static let statusMint = Color(red: 0.10, green: 0.75, blue: 0.60)
    public static let statusYellow = Color(red: 0.96, green: 0.71, blue: 0.18)
    public static let statusOrange = Color(red: 0.96, green: 0.50, blue: 0.15)
    public static let statusRed = Color(red: 0.92, green: 0.26, blue: 0.21)
    
    // UI Helpers
    public static func color(forRisk risk: RouteRiskLevel) -> Color {
        switch risk {
        case .safe: return statusGreen
        case .low: return statusMint
        case .medium: return statusYellow
        case .high: return statusOrange
        case .critical: return statusRed
        }
    }
    
    public static func color(forSlackRisk risk: SlackRiskLevel) -> Color {
        switch risk {
        case .safe: return statusGreen
        case .low: return statusMint
        case .medium: return statusYellow
        case .high: return statusOrange
        case .critical: return statusRed
        }
    }
}

// Glassmorphism Container Modifier
public struct GlassmorphicCardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground.opacity(0.85))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.cardBorder.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

public extension View {
    func glassmorphicCard() -> some View {
        self.modifier(GlassmorphicCardModifier())
    }
}
