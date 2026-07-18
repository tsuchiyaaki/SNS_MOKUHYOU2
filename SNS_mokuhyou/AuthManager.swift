//
//  AuthManager.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/18.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var isSignedIn = false
    @Published var errorMessage: String?

    var userID: String? {
        Auth.auth().currentUser?.uid
    }

    func signInIfNeeded() {
        if Auth.auth().currentUser != nil {
            isSignedIn = true
            return
        }

        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self else { return }

            if let error {
                errorMessage = "ログインに失敗しました：\(error.localizedDescription)"
                isSignedIn = false
                return
            }

            isSignedIn = result?.user != nil
        }
    }
}
