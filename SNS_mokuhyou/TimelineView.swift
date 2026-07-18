import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var postStore: PostStore
    @State private var showNewPost = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.88, green: 0.92, blue: 0.98)
                    .ignoresSafeArea()

                if !authManager.isSignedIn {
                    ProgressView("ログイン中…")
                } else if userStore.isLoading || postStore.isLoading {
                    ProgressView("データを読み込み中…")
                } else {
                    timelineContent
                }
            }
            .task(id: authManager.isSignedIn) {
                if authManager.isSignedIn {
                    await userStore.prepareCurrentUser()
                    postStore.startListening()
                } else {
                    authManager.signInIfNeeded()
                }
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
            .alert("エラー", isPresented: Binding(
                get: {
                    authManager.errorMessage != nil ||
                    userStore.errorMessage != nil ||
                    postStore.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        authManager.errorMessage = nil
                        userStore.errorMessage = nil
                        postStore.errorMessage = nil
                    }
                }
            )) {
                Button("もう一度試す") {
                    Task {
                        authManager.errorMessage = nil
                        userStore.errorMessage = nil
                        postStore.errorMessage = nil

                        if authManager.isSignedIn {
                            await userStore.prepareCurrentUser()
                            postStore.stopListening()
                            postStore.startListening()
                        } else {
                            authManager.signInIfNeeded()
                        }
                    }
                }
                Button("閉じる", role: .cancel) {}
            } message: {
                Text(
                    authManager.errorMessage ??
                    userStore.errorMessage ??
                    postStore.errorMessage ??
                    "不明なエラーです"
                )
            }
        }
    }

    private var timelineContent: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                NavigationLink {
                    MyAcountView()
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .padding(.trailing, 20)
                }
            }

            if postStore.posts.isEmpty {
                ContentUnavailableView(
                    "まだ投稿がありません",
                    systemImage: "text.bubble",
                    description: Text("右下の＋から最初の投稿を作ってみよう")
                )
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        ForEach(postStore.posts) { post in
                            FeedCard(post: post, iconColor: .red)
                                .contextMenu {
                                    if post.authorID == authManager.userID {
                                        Button(role: .destructive) {
                                            Task {
                                                await postStore.deletePost(post)
                                            }
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showNewPost = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .frame(width: 70, height: 70)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.trailing, 35)
            .padding(.bottom, 30)
        }
    }
}
