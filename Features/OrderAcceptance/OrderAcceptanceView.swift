import SwiftUI

public struct OrderAcceptanceView: View {
    @Bindable var viewModel: OrderAcceptanceViewModel
    public let candidateOrder: Order
    public let currentRoute: RouteCandidate
    public let existingOrders: [Order]
    public let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        viewModel: OrderAcceptanceViewModel,
        candidateOrder: Order,
        currentRoute: RouteCandidate,
        existingOrders: [Order],
        onComplete: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.candidateOrder = candidateOrder
        self.currentRoute = currentRoute
        self.existingOrders = existingOrders
        self.onComplete = onComplete
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isEvaluating {
                            ProgressView("Simulating route insertion...")
                                .padding(40)
                        } else if let eval = viewModel.evaluation {
                            // Decision Recommendation Card
                            VStack(spacing: 12) {
                                Text(eval.decision.title)
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(color(forDecision: eval.decision))
                                
                                Text(eval.explanation)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(color(forDecision: eval.decision).opacity(0.15))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(color(forDecision: eval.decision).opacity(0.4), lineWidth: 1.5)
                            )
                            
                            // Comparison Metrics Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SIMULATION COMPARISON")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Current Route")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f km", eval.baselineRoute.totalDistanceKm))
                                            .font(.headline)
                                        Text("Risk: \(eval.baselineRoute.risk.riskLevel.rawValue.uppercased())")
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.color(forRisk: eval.baselineRoute.risk.riskLevel))
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("With Order #\(candidateOrder.orderNumber)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f km", eval.candidateRoute.totalDistanceKm))
                                            .font(.headline)
                                        Text("Risk: \(eval.candidateRoute.risk.riskLevel.rawValue.uppercased())")
                                            .font(.caption2)
                                            .foregroundColor(AppTheme.color(forRisk: eval.candidateRoute.risk.riskLevel))
                                    }
                                }
                                
                                Divider().background(AppTheme.cardBorder)
                                
                                HStack {
                                    Text("Added Distance:")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("+\(String(format: "%.1f", eval.addedDistanceKm)) km")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.primaryOrange)
                                }
                                
                                HStack {
                                    Text("Added Travel Time:")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("+\(Int(eval.addedTravelTimeMinutes)) min")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.accentTeal)
                                }
                            }
                            .padding(16)
                            .glassmorphicCard()
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    Task {
                                        try? await viewModel.acceptOrder(candidateOrder)
                                        onComplete()
                                        dismiss()
                                    }
                                }) {
                                    Text("ACCEPT ORDER")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppTheme.primaryOrange)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: { dismiss() }) {
                                    Text("DECLINE ORDER")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Order Acceptance")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.evaluateNewOrder(candidateOrder, currentRoute: currentRoute, existingOrders: existingOrders)
            }
        }
    }
    
    private func color(forDecision decision: InsertionDecision) -> Color {
        switch decision {
        case .safeToAdd: return AppTheme.statusGreen
        case .addWithRisk: return AppTheme.statusYellow
        case .doNotAdd: return AppTheme.statusRed
        }
    }
}
