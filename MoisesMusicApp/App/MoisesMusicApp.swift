import SwiftUI
import SwiftData

@main
struct MoisesMusicApp: App {
    @StateObject private var container = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .preferredColorScheme(.dark)
        }
        .modelContainer(container.modelContainer)
    }
}
