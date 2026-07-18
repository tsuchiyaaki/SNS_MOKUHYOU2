//
//  PostStore.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/18.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

enum PostStoreError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        "ログインが完了していません。少し待ってからもう一度試してください。"
    }
}

@MainActor
final class PostStore: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    private var db: Firestore {
        Firestore.firestore()
    }

    func startListening() {
        guard listener == nil else { return }

        isLoading = true
        listener = db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    errorMessage = "投稿の読込に失敗しました：\(error.localizedDescription)"
                    isLoading = false
                    return
                }

                posts = snapshot?.documents.compactMap {
                    Post(document: $0)
                } ?? []
                isLoading = false
            }
    }

    func addPost(
        authorName: String,
        subject: String,
        change: String,
        selectedDate: String,
        selectedChange: String
    ) async throws {
        guard let authorID = Auth.auth().currentUser?.uid else {
            throw PostStoreError.notSignedIn
        }

        let data: [String: Any] = [
            "authorName": authorName,
            "subject": subject,
            "change": change,
            "selectedDate": selectedDate,
            "selectedChange": selectedChange,
            "authorID": authorID,
            "createdAt": FieldValue.serverTimestamp()
        ]

        _ = try await db.collection("posts").addDocument(data: data)
    }

    func deletePost(_ post: Post) async {
        guard post.authorID == Auth.auth().currentUser?.uid else {
            errorMessage = "自分の投稿だけ削除できます。"
            return
        }

        do {
            try await db.collection("posts").document(post.id).delete()
        } catch {
            errorMessage = "削除に失敗しました：\(error.localizedDescription)"
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
