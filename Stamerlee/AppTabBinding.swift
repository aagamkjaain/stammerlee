import SwiftUI

// MARK: - Shared Tab Navigation
public extension AppState {
    var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { self.selectedTab },
            set: { self.selectTab($0) }
        )
    }
}
