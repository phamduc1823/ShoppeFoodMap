import SwiftUI

public extension View {
    @ViewBuilder
    func inlineNavigationBarTitle() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

public extension ToolbarItemPlacement {
    static var platformTopBarTrailing: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarTrailing
        #else
        return .automatic
        #endif
    }
    
    static var platformTopBarLeading: ToolbarItemPlacement {
        #if os(iOS)
        return .topBarLeading
        #else
        return .cancellationAction
        #endif
    }
}
