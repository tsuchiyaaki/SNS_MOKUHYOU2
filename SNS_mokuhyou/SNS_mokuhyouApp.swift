import SwiftUI
import FirebaseAppCheck
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppCheck.setAppCheckProviderFactory(EvolglamAppCheckProviderFactory())
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
    @AppStorage("acceptedTermsVersion") private var acceptedTermsVersion = ""

    var body: some Scene {
        WindowGroup {
            Group {
                if acceptedTermsVersion == AppConfiguration.termsVersion {
                    TabView {
                        TimelineView()
                            .tabItem {
                                Label("タイムライン", systemImage: "house.fill")
                            }

                        NavigationStack {
                            SearchView()
                        }
                        .tabItem {
                            Label("検索", systemImage: "magnifyingglass")
                        }
                    }
                    .tint(.red)
                } else {
                    TermsAgreementView {
                        acceptedTermsVersion = AppConfiguration.termsVersion
                    }
                }
            }
            .environmentObject(authManager)
            .environmentObject(userStore)
            .environmentObject(postStore)
        }
    }
}
