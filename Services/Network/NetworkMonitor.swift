import Foundation
import Network
import Combine

/// Monitors network connectivity state for online vs offline routing mode switching.
@Observable
public final class NetworkMonitor: @unchecked Sendable {
    public static let shared = NetworkMonitor()
    
    public private(set) var isConnected: Bool = true
    public private(set) var isExpensive: Bool = false
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.shoppefoodmap.networkmonitor")
    
    public init() {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                self?.isExpensive = path.isExpensive
            }
        }
        self.monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
