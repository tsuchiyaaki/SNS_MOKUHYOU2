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
    case cannotModerateOwnPost

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "ログインが完了していません。少し待ってからもう一度試してください。"
        case .cannotModerateOwnPost:
            return "自分の投稿にはこの操作を行えません。"
        }
    }
}

struct BlockedUser: Identifiable {
    let id: String
    let displayName: String
}

@MainActor
final class PostStore: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var blockedUsers: [BlockedUser] = []
    @Published private(set) var isLoading = true
    @Published var errorMessage: String?

    private var allPosts: [Post] = []
    private var blockedUserIDs: Set<String> = []
    private var hiddenPostIDs: Set<String> = []
    private var postListener: ListenerRegistration?
    private var blockedUsersListener: ListenerRegistration?
    private var hiddenPostsListener: ListenerRegistration?

    private var db: Firestore {
        Firestore.firestore()
    }

    func startListening() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = PostStoreError.notSignedIn.localizedDescription
            isLoading = false
            return
        }

        if postListener == nil {
            isLoading = true
            postListener = db.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }

                    if let error {
                        errorMessage = "投稿の読込に失敗しました：\(error.localizedDescription)"
                        isLoading = false
                        return
                    }

                    allPosts = snapshot?.documents.compactMap {
                        Post(document: $0)
                    } ?? []
                    applySafetyFilters()
                    isLoading = false
                }
        }

        if blockedUsersListener == nil {
            blockedUsersListener = db.collection("users")
                .document(userID)
                .collection("blockedUsers")
                .order(by: "blockedAt", descending: true)
                .limit(to: 200)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }

                    if let error {
                        errorMessage = "ブロック情報の読込に失敗しました：\(error.localizedDescription)"
                        return
                    }

                    let documents = snapshot?.documents ?? []
                    blockedUserIDs = Set(documents.map(\.documentID))
                    blockedUsers = documents.map {
                        BlockedUser(
                            id: $0.documentID,
                            displayName: $0.data()["displayName"] as? String ?? "ユーザー"
                        )
                    }
                    .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
                    applySafetyFilters()
                }
        }

        if hiddenPostsListener == nil {
            hiddenPostsListener = db.collection("users")
                .document(userID)
                .collection("hiddenPosts")
                .order(by: "hiddenAt", descending: true)
                .limit(to: 200)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }

                    if let error {
                        errorMessage = "非表示情報の読込に失敗しました：\(error.localizedDescription)"
                        return
                    }

                    hiddenPostIDs = Set(snapshot?.documents.map(\.documentID) ?? [])
                    applySafetyFilters()
                }
        }
    }

    private func applySafetyFilters() {
        posts = allPosts.filter {
            !blockedUserIDs.contains($0.authorID) &&
            !hiddenPostIDs.contains($0.id)
        }
    }

    func hidePost(_ post: Post) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw PostStoreError.notSignedIn
        }

        hiddenPostIDs.insert(post.id)
        applySafetyFilters()

        do {
            try await db.collection("users")
                .document(userID)
                .collection("hiddenPosts")
                .document(post.id)
                .setData([
                    "postID": post.id,
                    "authorID": post.authorID,
                    "hiddenAt": FieldValue.serverTimestamp()
                ])
        } catch {
            hiddenPostIDs.remove(post.id)
            applySafetyFilters()
            throw error
        }
    }

    func reportPost(_ post: Post, reason: ReportReason) async throws {
        guard let reporterID = Auth.auth().currentUser?.uid else {
            throw PostStoreError.notSignedIn
        }
        guard post.authorID != reporterID else {
            throw PostStoreError.cannotModerateOwnPost
        }

        hiddenPostIDs.insert(post.id)
        applySafetyFilters()

        let reportID = "\(reporterID)_\(post.id)"
        let reportReference = db.collection("reports").document(reportID)
        let hiddenReference = db.collection("users")
            .document(reporterID)
            .collection("hiddenPosts")
            .document(post.id)
        let batch = db.batch()

        batch.setData([
            "reporterID": reporterID,
            "postID": post.id,
            "reportedUserID": post.authorID,
            "reason": reason.rawValue,
            "postAuthorName": post.authorName,
            "postSubject": post.subject,
            "postChange": post.change,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ], forDocument: reportReference)
        batch.setData([
            "postID": post.id,
            "authorID": post.authorID,
            "hiddenAt": FieldValue.serverTimestamp()
        ], forDocument: hiddenReference)

        do {
            try await batch.commit()
        } catch {
            hiddenPostIDs.remove(post.id)
            applySafetyFilters()
            throw error
        }
    }

    func blockUser(authorID: String, displayName: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw PostStoreError.notSignedIn
        }
        guard authorID != userID else {
            throw PostStoreError.cannotModerateOwnPost
        }

        blockedUserIDs.insert(authorID)
        blockedUsers.removeAll { $0.id == authorID }
        blockedUsers.append(BlockedUser(id: authorID, displayName: displayName))
        applySafetyFilters()

        do {
            try await db.collection("users")
                .document(userID)
                .collection("blockedUsers")
                .document(authorID)
                .setData([
                    "blockedUserID": authorID,
                    "displayName": displayName,
                    "blockedAt": FieldValue.serverTimestamp()
                ])
        } catch {
            blockedUserIDs.remove(authorID)
            blockedUsers.removeAll { $0.id == authorID }
            applySafetyFilters()
            throw error
        }
    }

    func unblockUser(_ blockedUser: BlockedUser) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw PostStoreError.notSignedIn
        }

        try await db.collection("users")
            .document(userID)
            .collection("blockedUsers")
            .document(blockedUser.id)
            .delete()

        blockedUserIDs.remove(blockedUser.id)
        blockedUsers.removeAll { $0.id == blockedUser.id }
        applySafetyFilters()
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

        try ContentSafetyFilter.validate(authorName, subject, change)

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
        postListener?.remove()
        blockedUsersListener?.remove()
        hiddenPostsListener?.remove()
        postListener = nil
        blockedUsersListener = nil
        hiddenPostsListener = nil
    }
}
