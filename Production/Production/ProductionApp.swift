import SwiftUI
import AppDependency

@main
struct ProductionApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ProductionDependency.rootView()
        }
    }
}
