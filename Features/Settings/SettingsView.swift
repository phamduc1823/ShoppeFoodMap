import SwiftUI

public struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    
    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundDark.ignoresSafeArea()
                
                Form {
                    Section("Scoring Weights") {
                        VStack(alignment: .leading) {
                            Text("Lateness Penalty Weight: \(Int(viewModel.config.weights.latenessWeightPerMinLinear))")
                            Slider(value: $viewModel.config.weights.latenessWeightPerMinLinear, in: 10...200, step: 5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Distance Weight (per km): \(String(format: "%.1f", viewModel.config.weights.distanceWeightPerKm))")
                            Slider(value: $viewModel.config.weights.distanceWeightPerKm, in: 0.1...10.0, step: 0.5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Waiting Time Weight (per min): \(String(format: "%.1f", viewModel.config.weights.waitingWeightPerMin))")
                            Slider(value: $viewModel.config.weights.waitingWeightPerMin, in: 0.1...5.0, step: 0.1)
                        }
                    }
                    
                    Section("Risk Slack Thresholds (Minutes)") {
                        VStack(alignment: .leading) {
                            Text("High Risk Threshold: < \(Int(viewModel.config.highSlackMinutesThreshold)) min buffer")
                            Slider(value: $viewModel.config.highSlackMinutesThreshold, in: 1...15, step: 1)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Medium Risk Threshold: < \(Int(viewModel.config.mediumSlackMinutesThreshold)) min buffer")
                            Slider(value: $viewModel.config.mediumSlackMinutesThreshold, in: 10...45, step: 5)
                        }
                    }
                    
                    Section("Offline Speed Assumptions") {
                        VStack(alignment: .leading) {
                            Text("Urban Driving Speed: \(String(format: "%.1f", viewModel.config.defaultUrbanSpeedMetersPerSec * 3.6)) km/h")
                        }
                    }
                    
                    Section {
                        Button("Reset to Factory Defaults") {
                            viewModel.resetToDefaults()
                        }
                        .foregroundColor(AppTheme.statusOrange)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Optimizer Settings")
        }
    }
}
