import SwiftUI
import AppDependency

@main
struct ProductionApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ProductionDependency.rootView()
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                break
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                fatalError()
            }
        }
    }
}
