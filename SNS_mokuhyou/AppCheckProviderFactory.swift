import FirebaseAppCheck
import FirebaseCore

final class EvolglamAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if DEBUG
        // Simulator・開発端末用。デバッグトークンはリポジトリに保存しない。
        return AppCheckDebugProvider(app: app)
        #else
        // App Store配布ビルドではApp Attestで正規アプリを検証する。
        return AppAttestProvider(app: app)
        #endif
    }
}
