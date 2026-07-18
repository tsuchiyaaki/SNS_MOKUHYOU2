//
//  UserStore.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/18.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

enum UserStoreError: LocalizedError {
    case notSignedIn
    case profileNotFound
    case invalidInput

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "ログインが完了していません。"
        case .profileNotFound:
            return "プロフィールを読み込めませんでした。"
        case .invalidInput:
            return "名前は1〜20文字、自己紹介は100文字以内で入力してください。"
        }
    }
}

@MainActor
final class UserStore: ObservableObject {
    @Published private(set) var currentUser: UserProfile?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    private var db: Firestore {
        Firestore.firestore()
    }

    func prepareCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = UserStoreError.notSignedIn.localizedDescription
            return
        }

        isLoading = true
        let reference = db.collection("users").document(uid)

        do {
            let snapshot = try await reference.getDocument()

            if !snapshot.exists {
                try await reference.setData([
                    "userName": "ゲスト",
                    "accountID": "guest_\(uid)",
                    "profileImageURL": "",
                    "bio": "",
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp()
                ])
            }

            startListening(userID: uid)
        } catch {
            errorMessage = "プロフィールの準備に失敗しました：\(error.localizedDescription)"
            isLoading = false
        }
    }

    private func startListening(userID: String) {
        listener?.remove()

        listener = db.collection("users").document(userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    errorMessage = "プロフィールの読込に失敗しました：\(error.localizedDescription)"
                    isLoading = false
                    return
                }

                guard
                    let snapshot,
                    snapshot.exists,
                    let data = snapshot.data(),
                    let userName = data["userName"] as? String,
                    let accountID = data["accountID"] as? String
                else {
                    errorMessage = UserStoreError.profileNotFound.localizedDescription
                    isLoading = false
                    return
                }

                let profile = UserProfile(
                    id: snapshot.documentID,
                    userName: userName,
                    accountID: accountID,
                    profileImageURL: data["profileImageURL"] as? String ?? "",
                    bio: data["bio"] as? String ?? ""
                )

                currentUser = profile
                isLoading = false
            }
    }

    func updateProfile(
        userName: String,
        bio: String
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw UserStoreError.notSignedIn
        }

        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            (1...20).contains(trimmedName.count),
            trimmedBio.count <= 100
        else {
            throw UserStoreError.invalidInput
        }

        try await db.collection("users").document(uid).updateData([
            "userName": trimmedName,
            "bio": trimmedBio,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
