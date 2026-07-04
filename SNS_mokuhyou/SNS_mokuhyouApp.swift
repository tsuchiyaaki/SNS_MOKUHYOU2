import SwiftUI
import SwiftData

@main
struct SNS_mokuhyouApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Post.self,        // Item.self から Post.self に変更
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TimelineView()
        }
        .modelContainer(sharedModelContainer)
    }
}
