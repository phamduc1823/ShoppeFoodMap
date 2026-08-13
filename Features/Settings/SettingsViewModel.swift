import Foundation
import SwiftUI

@Observable
public final class SettingsViewModel: @unchecked Sendable {
    public var config: OptimizationConfiguration
    
    public init(config: OptimizationConfiguration = .default) {
        self.config = config
    }
    
    public func resetToDefaults() {
        self.config = .default
    }
}
