import SwiftUI

struct ModeratedPostCard: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var postStore: PostStore

    let post: Post
    var iconColor: Color = .red

    @State private var showsReportReasons = false
    @State private var confirmsBlock = false
    @State private var confirmsDelete = false
    @State private var errorMessage: String?

    private var isOwnPost: Bool {
        post.authorID == authManager.userID
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            FeedCard(post: post, iconColor: iconColor)

            Menu {
                if isOwnPost {
                    Button(role: .destructive) {
                        confirmsDelete = true
                    } label: {
                        Label("投稿を削除", systemImage: "trash")
                    }
                } else {
                    Button {
                        showsReportReasons = true
                    } label: {
                        Label("この投稿を通報", systemImage: "exclamationmark.bubble")
                    }

                    Button {
                        perform {
                            try await postStore.hidePost(post)
                        }
                    } label: {
                        Label("この投稿を非表示", systemImage: "eye.slash")
                    }

                    Button(role: .destructive) {
                        confirmsBlock = true
                    } label: {
                        Label("投稿者をブロック", systemImage: "person.crop.circle.badge.xmark")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.gray, .white)
                    .padding(18)
            }
            .accessibilityLabel("投稿のメニュー")
        }
        .confirmationDialog(
            "通報理由を選択",
            isPresented: $showsReportReasons,
            titleVisibility: .visible
        ) {
            ForEach(ReportReason.allCases) { reason in
                Button(reason.rawValue) {
                    perform {
                        try await postStore.reportPost(post, reason: reason)
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("通報するとこの投稿はすぐに非表示になり、運営が24時間以内に確認します。")
        }
        .alert("投稿者をブロック", isPresented: $confirmsBlock) {
            Button("ブロック", role: .destructive) {
                perform {
                    try await postStore.blockUser(
                        authorID: post.authorID,
                        displayName: post.authorName
                    )
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("\(post.authorName)さんの投稿はすべて非表示になります。")
        }
        .alert("投稿を削除", isPresented: $confirmsDelete) {
            Button("削除", role: .destructive) {
                Task {
                    await postStore.deletePost(post)
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("削除した投稿は元に戻せません。")
        }
        .alert("操作できませんでした", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "不明なエラーです")
        }
    }

    private func perform(_ operation: @escaping () async throws -> Void) {
        Task {
            do {
                try await operation()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
