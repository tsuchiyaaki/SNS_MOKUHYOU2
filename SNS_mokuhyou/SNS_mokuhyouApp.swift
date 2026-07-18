import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SNS_mokuhyouApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var userStore = UserStore()
    @StateObject private var postStore = PostStore()

    var body: some Scene {
        WindowGroup {
            TimelineView()
            .environmentObject(authManager)
            .environmentObject(userStore)
            .environmentObject(postStore)
        }
    }
}
