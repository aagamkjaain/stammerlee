import SwiftUI
import TipKit

@main
struct StamerleeApp: App {
    init() {
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(StamerleeTheme.primaryPurple)
        }
    }
}
